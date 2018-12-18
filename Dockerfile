# from https://github.com/jupyter/docker-stacks/tree/14fdfbf9cfc1/scipy-notebook
FROM jupyter/scipy-notebook:14fdfbf9cfc1

USER $NB_UID

# add ydata favicon to notebook 
COPY favicon.ico /tmp/favicon.ico
RUN cp /tmp/favicon.ico $(dirname $(python -c 'import notebook; print(notebook.__file__)'))/static/base/images/favicon.ico

# nbresuse to show users memory usage
RUN pip install nbresuse==0.3.0 && \
	jupyter serverextension enable  --sys-prefix --py nbresuse && \
	jupyter nbextension     install --sys-prefix --py nbresuse && \
	jupyter nbextension     enable  --sys-prefix --py nbresuse

# interact notebook extension
RUN pip install nbgitpuller==0.6.1 && \
	jupyter serverextension enable  --sys-prefix --py nbgitpuller

# Install nbzip
RUN pip install nbzip==0.1.0 && \
    jupyter serverextension enable  --sys-prefix --py nbzip && \
    jupyter nbextension     install --sys-prefix --py nbzip && \
    jupyter nbextension     enable  --sys-prefix --py nbzip

COPY ipython_config.py ${IPYTHONDIR}/ipython_config.py

## add conda install commands here BEFORE pip installs, leave fix-permissions commands at end 
RUN conda install --yes 'astropy=3.1' && \
    conda clean -tipsy && \
    pip install --no-cache-dir git+https://github.com/data-8/Gofer-Grader.git@v0.4 && \
    pip install --no-cache-dir datascience==0.10.6 && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# HACK: We wanna make sure students don't hit the 60/hr/IP limit for github
# So we just put in a Personal Access Token for a dummy here.
# FIXME: Move the token to travis encrypted secrets
ENV NETRC /opt/conda/.netrc
COPY netrc-gen /tmp/netrc-gen
RUN /tmp/netrc-gen ${NETRC}

EXPOSE 8888
