import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
const loader = (name: string) => glob({ pattern: '**/[!_]*.md', base: `./content/${name}` });
const pages = defineCollection({
  loader: loader('pages'),
  schema: z.object({
    title: z.string(),
    subtitle: z.string().optional(),
    description: z.string().optional(),
  }),
});
const news = defineCollection({
  loader: loader('news'),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    summary: z.string(),
    cover_image: z.string().default('photo_56.jpg'),
    tags: z.array(z.string()).default([]),
    photos_album_url: z.string().url().optional(),
    photos_count: z.number().optional(),
    lichess_study_url: z.string().url().optional(),
    featured: z.boolean().default(false),
  }),
});
const coaches = defineCollection({
  loader: loader('coaches'),
  schema: z.object({
    name: z.string(),
    role: z.string(),
    title_fide: z.string().optional(),
    order: z.number().default(10),
  }),
});
const performances = defineCollection({
  loader: loader('performances'),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    category: z.string(),
    medals: z.string().optional(),
    order: z.number().default(10),
  }),
});
const galleries = defineCollection({
  loader: loader('galleries'),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    location: z.string(),
    cover_image: z.string(),
    photos: z.array(z.object({ file: z.string(), alt: z.string() })).default([]),
    photos_album_url: z.string().url().optional(),
    photos_count: z.number().optional(),
  }),
});
const home = defineCollection({
  loader: loader('home'),
  schema: z.object({ title: z.string(), lead: z.string(), eyebrow: z.string() }),
});
export const collections = { pages, news, coaches, performances, galleries, home };
