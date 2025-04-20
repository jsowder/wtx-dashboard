# Use base image with Shiny Server
FROM rocker/shiny

RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    curl \
    gdebi-core \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb

# Install R packages
RUN R -e "install.packages(c('shiny', 'quarto', 'tidyverse', 'sf', 'DT', 'mapgl', 'remotes'), type = 'source')"
RUN R -e "remotes::install_github('jsowder/wtx')"

# Configure Shiny Server
RUN mkdir -p /srv/shiny-server/dashboard && \
    chown -R shiny:shiny /srv/shiny-server
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Ensure correct permissions to delete logs
RUN mkdir -p /var/log/shiny-server && \
    chown -R shiny:shiny /var/log/shiny-server

# Render dashboard
COPY index.qmd /srv/shiny-server/dashboard/index.qmd
WORKDIR /srv/shiny-server/dashboard/
RUN quarto render index.qmd

# Switch to non-root user
USER shiny

# Run Shiny Server
CMD ["/usr/bin/shiny-server"]
