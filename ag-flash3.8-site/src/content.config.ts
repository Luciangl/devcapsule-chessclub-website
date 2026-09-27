import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const news = defineCollection({
  loader: glob({ pattern: '**/[!_]*.md', base: './content/news' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    summary: z.string(),
    cover_image: z.string().optional(),
    tags: z.array(z.string()).default([]),
    photos_album_url: z.string().optional(),
    photos_count: z.number().optional(),
    lichess_study_url: z.string().optional(),
    lichess_game_id: z.string().optional(),
    featured: z.boolean().default(false),
  }),
});

const coaches = defineCollection({
  loader: glob({ pattern: '**/[!_]*.md', base: './content/coaches' }),
  schema: z.object({
    name: z.string(),
    role: z.string(),
    title_fide: z.string().optional(),
    fide_id: z.string().optional(),
    photo: z.string().optional(),
    order: z.number().default(10),
    phone: z.string().optional(),
    email: z.string().optional(),
  }),
});

const performances = defineCollection({
  loader: glob({ pattern: '**/[!_]*.md', base: './content/performances' }),
  schema: z.object({
    title: z.string(),
    year: z.number(),
    category: z.string(),
    medals: z.string().optional(),
    order: z.number().default(10),
  }),
});

const pages = defineCollection({
  loader: glob({ pattern: '**/[!_]*.md', base: './content/pages' }),
  schema: z.object({
    title: z.string(),
    subtitle: z.string().optional(),
    description: z.string().optional(),
  }),
});

export const collections = { news, coaches, performances, pages };
