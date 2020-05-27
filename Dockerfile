FROM mcr.microsoft.com/dotnet/core/sdk:3.1

RUN apt install -y --no-install-recommends wget && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Set non-root user
ENV USER="user"
ENV NB_UID="1000"
RUN useradd -ms /bin/bash $USER
USER $USER 
ENV HOME="/home/$USER"
WORKDIR $HOME

# Install Anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O anaconda.sh
RUN chmod +x anaconda.sh
RUN ./anaconda.sh -b -p $HOME/anaconda
RUN rm ./anaconda.sh
ENV PATH="/${HOME}/anaconda/bin:${PATH}"

# Copy notebooks
USER ROOT
COPY ./notebooks/ ${HOME}/notebooks/
RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

# Install .NET kernel
RUN dotnet tool install -g --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json" Microsoft.dotnet-interactive
ENV PATH="/${HOME}/.dotnet/tools:${PATH}"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN dotnet interactive jupyter install



# Run Jupyter Notebook
EXPOSE 8888
ENTRYPOINT ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0"]

# Copy package sources

#COPY ./NuGet.config ${HOME}/nuget.config

# Set root to Notebooks
WORKDIR ${HOME}/Notebooks/


