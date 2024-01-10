

# Reload package with local changes
remove.packages("FWSAkRDRtools")
.rs.restartR()

setwd("C:/Users/hvincelette/OneDrive - DOI/Documents/GitHub/FWSAkRDRtools")

devtools::load_all()
devtools::document(roclets = c('rd', 'collate', 'namespace'))
devtools::build_readme()
devtools::install()

# Write markdown
pkgdown::build_articles()
rmarkdown::render('vignettes/01_Intro_FWSAkRDRtools.Rmd')
rmarkdown::render('vignettes/02_Setup_FWSAkRDRtools.Rmd')
rmarkdown::render('vignettes/03_FWSAkRDRtools_Tutorial.Rmd')

# Update site
pkgdown::build_site(examples = FALSE)
pkgdown::build_site_github_pages(examples = FALSE)

# pkgdown::deploy_to_branch(
#   clean = TRUE,
#   branch = "gh-pages",
#   remote = "origin",
#   github_pages = (branch == "gh-pages"),
#   subdir = NULL,
#   examples = FALSE
# )

# pkgdown::clean_site()
# pkgdown::build_reference(examples = FALSE)
# pkgdown::build_site_github_pages(examples = FALSE)
# usethis::use_github_action("pkgdown")
# usethis::use_pkgdown_github_pages()
# usethis::browse_github_actions()
# "pages build and deployment"

# Install required packages
renv::snapshot()

# Update token
gitcreds::gitcreds_set()

# Update version
utils::package_version("0.0.2")
usethis::use_version("patch")
pkgdown::build_site(examples = FALSE)

# Add packages to DESCRIPTION
usethis::use_package("downloader")
usethis::use_pipe()

# Test functions
usethis::use_test("commit.files.R")
devtools::test('.')

# Create R script
usethis::use_r("summarize.proj.R")

# Save R objects
usethis::use_data(dir_template)

# Create project folders in directory
usethis::use_directory("docs")

# Check which packages used in function
rfile <- file.choose()
NCmisc::list.functions.in.file(rfile)

# Update license
usethis::use_gpl3_license()
usethis::use_mit_license()

# Create package zip
build()

# View package info
library(FWSAkRDRtools)
?  ? FWSAkRDRtools
help(package = "FWSAkRDRtools")
? FWSAkRDRtools::find.files
? FWSAkRDRtools::download.files
vignette("FWSAkRDRtools")


# TEST
setwd("C:/Users/hvincelette/OneDrive - DOI/Documents/Working_files/test")


FWSAkRDRtools::get.dir.template(
  project = "mbmlb_909_Eskimo_Curlew_study",
  path = getwd(),
  main = TRUE,
  incoming = FALSE
)

FWSAkRDRtools::clone.project(project = "mbmlb_010_Grey_headed_chickadee_hybridization",
              path = getwd(),
              main = TRUE,
              incoming = TRUE)

e.g.summary <-
  FWSAkRDRtools::summarize.files(
    project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey",
    subfolder = c("analysis_output", "final_data", "metadata"),
    incoming = TRUE,
    main = FALSE
  )

FWSAkRDRtools::find.files(
  pattern = c("template", "dictionary", "\\.csv", "hello"),
  project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey",
  incoming = TRUE,
  main = FALSE,
  recursive = TRUE,
  full.path = FALSE
)

FWSAkRDRtools::download.files(
  pattern = c("template", "dictionary", "\\.xlsx", "\\?"),
  project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey",
  path = getwd(),
  incoming = TRUE,
  main = TRUE,
  recursive = TRUE,
  download.file.method = "curl"
)

e.g.tabular.data <-
  FWSAkRDRtools::read.tables(
    pattern = c("\\.csv", "\\.xlsx"),
    project = "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey",
    incoming = TRUE,
    main = TRUE,
    recursive = TRUE
  )

e.g.commit <-
  commit.files(project = "mbmlb_010_Grey_headed_chickadee_hybridization",
               local.folder = getwd(),
               recursive = TRUE)


# NOTES

fs::dir_tree(
  path = paste0(
    "//ifw7ro-file.fws.doi.net/datamgt/",
    "mbm",
    "/",
    "mbmlb_007_NWR_Alaska_Landbird_Monitoring_Survey/incoming/"
  ),
  recurse = TRUE
)













