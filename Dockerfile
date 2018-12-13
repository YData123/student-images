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

## add conda install commands here BEFORE pip installs
# RUN conda install --quiet --yes \
#    'examplemodule1=1.0.1' \
#    'examplemodule2=0.5*' \
#    conda clean -tipsy && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

## add pip install commands here AFTER conda installs
# RUN pip install --no-cache-dir examplemodule1==1.0.1

# HACK: We wanna make sure students don't hit the 60/hr/IP limit for github
# So we just put in a Personal Access Token for a dummy here.
# FIXME: Move the token to travis encrypted secrets
ENV NETRC /opt/conda/.netrc
COPY netrc-gen /tmp/netrc-gen
RUN /tmp/netrc-gen ${NETRC}

EXPOSE 8888
