FROM honomoa/miniconda:4.7.12-spark2.4.3

HEALTHCHECK CMD netstat -nl | egrep "8888" > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENV JUPYTER_USER=${CONDA_USER}
ENV JUPYTER_HOME=/home/${JUPYTER_USER}
ENV JUPYTER_VERSION=1.1.0
ENV TOREE_VERSION=0.3.0

USER root
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends net-tools curl netcat && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${JUPYTER_USER}
RUN conda install --quiet --yes \
    'notebook=6.0.3' \
    jupyterhub=${JUPYTER_VERSION} \
    'jupyterlab=1.2.5' \
    'beautifulsoup4=4.8.*' \
    'conda-forge::blas=*=openblas' \
    'bokeh=1.4.*' \
    'cloudpickle=1.2.*' \
    'cython=0.29.*' \
    'dask=2.9.*' \
    'dill=0.3.*' \
    'h5py=2.10.*' \
    'hdf5=1.10.*' \
    'ipywidgets=7.5.*' \
    'matplotlib-base=3.1.*' \
    'numba=0.48.*' \
    'numexpr=2.7.*' \
    'pandas=0.25.*' \
    'patsy=0.5.*' \
    'protobuf=3.11.*' \
    'scikit-image=0.16.*' \
    'scikit-learn=0.22.*' \
    'scipy=1.4.*' \
    'seaborn=0.9.*' \
    'sqlalchemy=1.3.*' \
    'statsmodels=0.11.*' \
    'sympy=1.5.*' \
    'vincent=0.4.*' \
    'xlrd' \
    'pyarrow' \
    'r-base=3.6.2' \
    'r-ggplot2=3.2*' \
    'r-irkernel=1.1*' \
    'r-rcurl=1.98*' \
    'r-sparklyr=1.1*' \
    'pyspark' && \
    conda clean --all -f -y && \
    jupyter notebook --generate-config

RUN conda install --quiet --yes tensorflow && \
    conda clean --all -f -y && \
    jupyter notebook --generate-config -y

# Apache Toree kernel
RUN pip install --no-cache-dir \
    https://dist.apache.org/repos/dist/release/incubator/toree/${TOREE_VERSION}-incubating/toree-pip/toree-${TOREE_VERSION}.tar.gz \
    && \
    jupyter toree install --sys-prefix && \
    rm -rf ${HOME}/.local

# Spylon-kernel
RUN conda install --quiet --yes 'spylon-kernel=0.4*' && \
    conda clean --all -f -y && \
    python -m spylon_kernel install --sys-prefix && \
    rm -rf ${HOME}/.local

# Unofficial Jupyter Notebook Extensions
RUN conda install -c conda-forge jupyter_contrib_nbextensions \
        jupyter_nbextensions_configurator && \
    conda clean --all -f -y && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextensions_configurator enable --user

RUN mkdir -p ${JUPYTER_HOME}/work
VOLUME [ ${JUPYTER_HOME}/work ]

USER root
COPY jupyter_notebook_config.py /etc/jupyter/
ADD run.sh /run.sh
RUN chmod a+x /run.sh

WORKDIR ${JUPYTER_HOME}

EXPOSE 8888

CMD ["/run.sh"]
