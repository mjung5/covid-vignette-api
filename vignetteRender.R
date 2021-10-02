# author:Min-Jung Jung
# date:10/01/2021
# Render covidVignette.Rmd to README.md file.

rmarkdown::render(
  input="covidVignette.Rmd",
  output_format="github_document",
  output_file = "README.md"
  output_options=list(html_preview=FALSE, keep_html=FALSE)
)

