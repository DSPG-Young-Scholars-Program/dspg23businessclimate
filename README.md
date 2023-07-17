# dspg23_website_template

Steps to use this template:

1. Within your project repository, decide where your working /web directory should be. The /docs directory will need to be at the project root.

2. Within your project repository, set the template as a remote

`git remote add template https://github.com/DSPG-Young-Scholars-Program/dspg23_website_template.git`

3. Fetch updates from the template

`git remote fetch --all`

4. Make necessary changes to the template main branch
  - Reconcile directory structures
  - DELETE the template README.md
  - DELETE the template .gitignore

5. Merge the template into your project repository

`git merge template/[branch_to_merge] --allow-unrelated-histories`

When the template is updated, repeat steps 3-5 only.
