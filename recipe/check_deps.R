# Check that the installed pdp's Depends/Imports are present and satisfy
# their version constraints in the test environment.
base_pkgs <- c("R", "base", "compiler", "datasets", "graphics", "grDevices",
               "grid", "methods", "parallel", "splines", "stats", "stats4",
               "tcltk", "tools", "utils")

desc <- packageDescription("pdp")
fields <- c(desc$Depends, desc$Imports)
fields <- fields[!is.na(fields)]
deps <- trimws(unlist(strsplit(paste(fields, collapse = ","), ",")))
deps <- deps[nzchar(deps)]

problems <- character()
for (dep in deps) {
  name <- sub("\\s*\\(.*$", "", dep)
  if (name %in% base_pkgs) next
  if (!requireNamespace(name, quietly = TRUE)) {
    problems <- c(problems, paste("missing:", name))
    next
  }
  constraint <- regmatches(dep, regexec("\\((>=|<=|==|>|<)\\s*([^)]+)\\)", dep))[[1]]
  if (length(constraint) == 3 &&
      !match.fun(constraint[2])(packageVersion(name), package_version(constraint[3]))) {
    problems <- c(problems, paste("version:", dep, "installed", packageVersion(name)))
  }
}
if (length(problems)) stop(paste(problems, collapse = "\n"))
cat("pdp dependencies OK\n")
