# data-linkage-practices

Best practices for data linkage in R, written for public health and epidemiology and useful for linkage work more generally.

## Website

Project site: <https://coraliewilliams.github.io/data-linkage-practices/>

## Purpose

This repository pairs short Quarto pages with longer R walkthroughs. The site is theory first, then applications, so readers can move from core linkage concepts to concrete workflows and reporting.

## Repository layout

- `index.qmd`, `about.qmd`, `checklist.qmd`, `scripts.qmd`: top-level site pages
- `theory/`: concise concept pages in reading order
- `applications/`: short application pages in reading order
- `R/`: standalone, heavily commented walkthrough scripts
- `data-raw/`: cached public downloads used by the scripts
- `_freeze/`: committed rendered outputs used by Quarto freeze
- `.github/workflows/publish.yml`: GitHub Pages deployment workflow
- `renv.lock`, `renv/`: reproducible R environment metadata

## Contributing

1. Create or activate the project environment with `renv::restore()`.
2. Run the standalone scripts you change from RStudio or `Rscript`.
3. Re-render the website locally with `quarto render` so `_freeze/` stays current.
4. Open a focused pull request with a short note on data sources, linkage choices, and any reporting implications.

## Local publish workflow

Run these commands from the repository root:

```bash
quarto render
git add README.md .gitignore .Rprofile CITATION.cff _quarto.yml about.qmd checklist.qmd index.qmd scripts.qmd styles.scss theory applications R data-raw renv renv.lock .github/workflows/publish.yml data-linkage-practices.Rproj _freeze
git commit -m "Build Quarto site scaffold"
git push origin main
```

Then enable GitHub Pages in the repository UI:

1. Open **Settings** → **Pages**.
2. Set **Source** to **Deploy from a branch**.
3. Choose the **gh-pages** branch and the **/(root)** folder.
4. Save.
