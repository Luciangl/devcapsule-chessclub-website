import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, cpSync, rmSync, symlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { assertUnbilled, prepare } from '../hosting.mjs';

const project = 'demo-rocada-spark';
const good = { projectId: project, billingEnabled: false, billingAccountName: '' };
test('billing guard requires exact project, false billing, and no account', () => {
  assert.doesNotThrow(() => assertUnbilled(good, project));
  assert.doesNotThrow(() => assertUnbilled({ projectId: project, billingEnabled: false }, project));
  for (const bad of [null, {}, { ...good, billingEnabled: true }, { ...good, billingEnabled: 'false' },
    { ...good, projectId: 'another-project' }, { ...good, billingAccountName: 'billingAccounts/123' },
    { ...good, billingAccountName: null }, { ...good, billingEnabled: undefined }]) {
    assert.throws(() => assertUnbilled(bad, project), /Refusing deployment/);
  }
});
function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), 'firebase-test-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const source = join(root, 'claude-rocada-site');
  mkdirSync(join(source, 'dist', 'contact'), { recursive: true });
  for (const file of ['index.html', '404.html', 'contact/index.html']) writeFileSync(join(source, 'dist', file), file);
  writeFileSync(join(source, 'package-lock.json'), '{}');
  return { root, source };
}
test('artifact includes only static dist content and explicit Hosting config', t => {
  const { root, source } = fixture(t);
  writeFileSync(join(source, 'secret.env'), 'not public');
  prepare(project, join(source, 'dist'), root);
  const config = JSON.parse(readFileSync(join(root, 'firebase.json')));
  assert.deepEqual(Object.keys(config), ['hosting']);
  assert.equal(config.hosting.site, project);
  assert.equal(config.hosting.rewrites, undefined);
  assert.equal(config.hosting.predeploy, undefined);
  assert.equal(readFileSync(join(root, 'public/contact/index.html'), 'utf8'), 'contact/index.html');
  assert.throws(() => readFileSync(join(root, 'public/secret.env')));
});
for (const hazard of ['symlink', 'hidden', 'missing404']) test(`rejects ${hazard} in build`, t => {
  const { root, source } = fixture(t);
  if (hazard === 'symlink') symlinkSync('/etc/hosts', join(source, 'dist/leak'));
  if (hazard === 'hidden') writeFileSync(join(source, 'dist/.env'), 'secret');
  if (hazard === 'missing404') rmSync(join(source, 'dist/404.html'));
  assert.throws(() => prepare(project, join(source, 'dist'), root));
});
function shellFixture(t, mode) {
  const { root } = fixture(t);
  const scripts = join(root, 'scripts/firebase');
  mkdirSync(join(scripts, 'node_modules/.bin'), { recursive: true });
  for (const file of ['common.sh', '01-create-project.sh', '02-deploy.sh', 'hosting.mjs']) {
    cpSync(new URL(`../${file}`, import.meta.url), join(scripts, file));
  }
  const bin = join(root, 'bin'); mkdirSync(bin);
  const log = join(root, 'calls'); writeFileSync(log, '');
  const stub = `#!${process.execPath}
const fs=require('node:fs'); const path=require('node:path');
const command=path.basename(process.argv[1]), args=process.argv.slice(2), mode=process.env.TEST_MODE;
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify({command,args,cwd:process.cwd()})+'\\n');
if(command==='gcloud') {
 if(args[0]==='projects') process.exit(mode==='existing'?1:0);
 if(mode==='api-error') process.exit(1);
 if(mode==='malformed') { console.log('invalid json'); process.exit(0); }
 const built=fs.existsSync(process.env.TEST_LOG+'.built');
 console.log(JSON.stringify({projectId:'${project}',billingEnabled:mode==='billed'||(mode==='changed'&&built),billingAccountName:''}));
} else if(command==='npm') fs.writeFileSync(process.env.TEST_LOG+'.built','yes');
else if(args[0]==='hosting:sites:list') console.log(JSON.stringify({status:'success',result:{sites:mode==='new-site'?[]:[{name:'projects/${project}/sites/${project}'}]}}));
else if(args[0]==='deploy') {
 const config=JSON.parse(fs.readFileSync(args[args.indexOf('--config')+1]));
 if(config.hosting.site!=='${project}' || config.functions || config.hosting.rewrites) process.exit(2);
}
`;
  for (const name of ['gcloud', 'npm']) writeFileSync(join(bin, name), stub, { mode: 0o755 });
  writeFileSync(join(scripts, 'node_modules/.bin/firebase'), stub, { mode: 0o755 });
  const run = (script = '02-deploy.sh', options = []) => spawnSync('bash', [join(scripts, script), ...options, project], {
    cwd: root, encoding: 'utf8', env: { ...process.env, PATH: `${bin}:${process.env.PATH}`, TEST_LOG: log, TEST_MODE: mode },
  });
  const calls = () => readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse);
  return { run, calls, root };
}
for (const mode of ['billed', 'api-error', 'malformed', 'changed']) test(`deploy stops on ${mode}`, t => {
  const f = shellFixture(t, mode); const result = f.run();
  assert.notEqual(result.status, 0, result.stdout + result.stderr);
  assert.equal(f.calls().some(c => c.command === 'firebase'), false);
  assert.equal(f.calls().some(c => c.command === 'npm'), mode === 'changed');
});
for (const mode of ['spark', 'new-site']) test(`deploy ${mode}: isolated, explicit Hosting target`, t => {
  const f = shellFixture(t, mode); const result = f.run();
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const calls = f.calls(), deploy = calls.find(c => c.args[0] === 'deploy');
  assert.ok(deploy);
  assert.deepEqual(deploy.args.slice(0, 5), ['deploy', '--only', 'hosting', '--project', project]);
  assert.ok(!deploy.cwd.startsWith(f.root));
  assert.equal(calls.some(c => c.args[0] === 'hosting:sites:create'), mode === 'new-site');
  assert.ok(calls.filter(c => c.command === 'gcloud').length >= 3);
});
test('prepare-only needs no cloud calls', t => {
  const f = shellFixture(t, 'billed'); const result = f.run('02-deploy.sh', ['--prepare-only']);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(f.calls().map(c => c.command), ['npm']);
  const artifact = result.stdout.match(/no cloud access\): (.+)/)?.[1];
  assert.ok(artifact?.startsWith(resolve(tmpdir(), 'chessclub-firebase.')));
  rmSync(artifact, { recursive: true });
});
test('project creation never adopts an existing project', t => {
  const f = shellFixture(t, 'existing'); const result = f.run('01-create-project.sh');
  assert.notEqual(result.status, 0);
  assert.equal(f.calls().length, 1);
});
test('project creation checks billing before adding Firebase', t => {
  const f = shellFixture(t, 'billed'); const result = f.run('01-create-project.sh');
  assert.notEqual(result.status, 0);
  assert.equal(f.calls().some(c => c.command === 'firebase'), false);
});
