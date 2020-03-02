FROM honomoa/spark-base:2.4.3-hadoop3.1.2

# HEALTHCHECK CMD echo stat | nc localhost 8080 || exit 1

ENV CONDA_USER=conda
ENV CONDA_VERSION=4.7.12
ENV CONDA_CONF_DIR=/etc/conda
ENV CONDA_HOME=/opt/conda
ENV CONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
ENV PATH=$CONDA_HOME/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools curl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -N ${CONDA_USER} && \
    mkdir -p /opt/conda-4.7.12 && \
    chown ${CONDA_USER} /opt/conda-4.7.12

USER ${CONDA_USER}
RUN set -x \
    && curl -fSL "$CONDA_URL" -o /tmp/conda.sh \
    && /bin/bash /tmp/conda.sh -u -b -p /opt/conda-${CONDA_VERSION} \
    && /opt/conda-${CONDA_VERSION}/bin/conda clean -tipsy \
    && rm /tmp/conda.sh* \
    && /opt/conda-${CONDA_VERSION}/bin/conda config --system --prepend channels conda-forge \
    && /opt/conda-${CONDA_VERSION}/bin/conda config --system --set auto_update_conda false \
    && /opt/conda-${CONDA_VERSION}/bin/conda config --system --set show_channel_urls true \
    && /opt/conda-${CONDA_VERSION}/bin/conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> /opt/conda-${CONDA_VERSION}/conda-meta/pinned \
    && /opt/conda-${CONDA_VERSION}/bin/conda install --quiet --yes conda \
    && /opt/conda-${CONDA_VERSION}/bin/conda install --quiet --yes pip \
    && /opt/conda-${CONDA_VERSION}/bin/conda update --all --quiet --yes \
    && find /opt/conda-${CONDA_VERSION}/ -follow -type f -name '*.a' -delete \
    && find /opt/conda-${CONDA_VERSION}/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda-${CONDA_VERSION}/bin/conda clean --all -f -y \
    && rm -rf ${HOME}/.local

USER root
RUN ln -s /opt/conda-$CONDA_VERSION/conf $CONDA_CONF_DIR && \
    ln -s /opt/conda-$CONDA_VERSION $CONDA_HOME && \
    ln -s /opt/conda-${CONDA_VERSION}/etc/profile.d/conda.sh /etc/profile.d/conda.sh

USER ${CONDA_USER}

#COPY conda-site.xml $CONDA_CONF_DIR

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR $CONDA_HOME
CMD ["bin/conda.sh"]
