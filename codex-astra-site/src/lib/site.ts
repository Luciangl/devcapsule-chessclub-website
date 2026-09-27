export const site = {
  name: 'ACS Smart Galați',
  enrollmentUrl: 'https://forms.gle/smartgalati-inscriere',
  description:
    'Un loc pentru minți curioase. Cursuri de șah, antrenori dedicați și o comunitate care crește împreună, în Galați.',
};
export const dateLabel = (date: Date) =>
  new Intl.DateTimeFormat('ro-RO', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  }).format(date);
