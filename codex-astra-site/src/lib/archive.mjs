/** Date-only, UTC calendar cutoff. An item exactly two years old stays current. */
export function isArchived(date, now = new Date()) {
  const year = now.getUTCFullYear() - 2;
  const month = now.getUTCMonth();
  const day = Math.min(now.getUTCDate(), new Date(Date.UTC(year, month + 1, 0)).getUTCDate());
  return new Date(date).getTime() < Date.UTC(year, month, day);
}
export function articleUrl(entry, now = new Date()) {
  return isArchived(entry.data.date, now)
    ? `/arhiva/${entry.data.date.getUTCFullYear()}/${entry.id}/`
    : `/noutati/${entry.id}/`;
}
