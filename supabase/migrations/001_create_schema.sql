-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- Create enum for canticas
create type cantica_type as enum ('inferno', 'purgatorio', 'paradiso', 'general');

-- Create enum for languages
create type language_type as enum ('latin', 'italian', 'english');

-- Create enum for text types
create type text_type as enum ('commentary', 'poem', 'description', 'proemio', 'conclusione');

-- Commentaries table (modernized version of ddp_comm_tab)
create table public.dde_commentaries (
    id uuid default uuid_generate_v4() primary key,
    comm_id varchar(5) unique not null, -- Original 5-char ID for compatibility
    comm_name varchar(64) not null, -- Directory name
    comm_author varchar(256) not null,
    comm_lang language_type not null,
    comm_pub_year varchar(256),
    comm_biblio text,
    comm_editor varchar(256),
    comm_copyright boolean default false,
    comm_data_entry text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Texts table (modernized version of ddp_text_tab)
create table public.dde_texts (
    id uuid default uuid_generate_v4() primary key,
    doc_id varchar(12) unique not null, -- Original 12-char ID for compatibility
    commentary_id uuid references public.dde_commentaries(id) on delete cascade,
    cantica cantica_type not null,
    canto_id integer check (canto_id >= 0 and canto_id <= 34),
    start_line integer check (start_line >= 0),
    end_line integer check (end_line >= 0),
    text_language language_type not null,
    text_type text_type not null,
    source_path varchar(128),
    content text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes for performance
create index idx_dde_commentaries_comm_id on public.dde_commentaries(comm_id);
create index idx_dde_commentaries_comm_name on public.dde_commentaries(comm_name);
create index idx_dde_texts_doc_id on public.dde_texts(doc_id);
create index idx_dde_texts_commentary_id on public.dde_texts(commentary_id);
create index idx_dde_texts_cantica_canto on public.dde_texts(cantica, canto_id);
create index idx_dde_texts_content_gin on public.dde_texts using gin(to_tsvector('english', content));

-- Enable Row Level Security
alter table public.dde_commentaries enable row level security;
alter table public.dde_texts enable row level security;

-- Create policies for public read access (adjust as needed)
create policy "Allow public read access on dde_commentaries" on public.dde_commentaries
    for select using (true);

create policy "Allow public read access on dde_texts" on public.dde_texts
    for select using (true);

-- Create function to update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

-- Create triggers for updated_at
create trigger handle_dde_commentaries_updated_at
    before update on public.dde_commentaries
    for each row execute function public.handle_updated_at();

create trigger handle_dde_texts_updated_at
    before update on public.dde_texts
    for each row execute function public.handle_updated_at();
