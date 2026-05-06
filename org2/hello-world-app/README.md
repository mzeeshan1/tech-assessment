# hello-world-app
A repository containing simple http server that replies with hello world, and its corresponding helmchart
app folder contains the source code and dockerfile for the code
helmchart folder contains the helmchart for tha application
upon commits to main branch, gitlab ci builds the application, pushes the tags to ecr, updates image tag in helmchart values file, updates the chart version, packages and pushes chart to ecr.
