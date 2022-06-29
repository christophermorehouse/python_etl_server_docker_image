FROM openjdk:11.0.13

LABEL author="Christopher Morehouse"

# Set required environment vars
ENV PDI_RELEASE=9.3 \
    PDI_VERSION=9.3.0.0-428 \
    CARTE_PORT=9080 \
    PENTAHO_JAVA_HOME=/usr/local/openjdk-11 \
    KETTLE_HOME=/home/pentaho

# Create user
RUN mkdir ${KETTLE_HOME} && \
    groupadd -r pentaho && \
    useradd -s /bin/bash -d ${KETTLE_HOME} -r -g pentaho pentaho && \
    chown pentaho:pentaho ${KETTLE_HOME}

# Download and unzip Pentaho Data Integration
RUN /usr/bin/curl \
    -# \
    -L \
    --retry-all-errors \
    -0 \
    https://downloads.sourceforge.net/project/pentaho/Pentaho-${PDI_RELEASE}/client-tools/pdi-ce-${PDI_VERSION}.zip \
    -o /tmp/pdi-ce-${PDI_VERSION}.zip && \
    /usr/bin/unzip -q /tmp/pdi-ce-${PDI_VERSION}.zip -d ${KETTLE_HOME} && \
    rm /tmp/pdi-ce-${PDI_VERSION}.zip

# Add configuration and ETL files
RUN mkdir ${KETTLE_HOME}/docker-entrypoint.d ${KETTLE_HOME}/templates ${KETTLE_HOME}/scripts ${KETTLE_HOME}/data-integration/plugins/steps \
    ${KETTLE_HOME}/.kettle ${KETTLE_HOME}/etl_files ${KETTLE_HOME}/etl_files/python_scripts
COPY docker_build_files/pentaho_configuration_files/carte-*.config.xml ${KETTLE_HOME}/templates/
COPY docker_build_files/docker-entrypoint.sh ${KETTLE_HOME}/scripts/
COPY docker_build_files/pentaho_configuration_files/python_dependencies.txt ${KETTLE_HOME}/docker-entrypoint.d/
COPY docker_build_files/pentaho_configuration_files/python_plugins.zip ${KETTLE_HOME}/docker-entrypoint.d/

# Base image has python3 already installed. Install pip3, then install python dependencies required for ETL. 
# Note, python-is-pyton3 package also needs to be installed because PDI looks for and uses "python" 
# (which is probably python 2.7) in $PATH and as a result cannot use pip3. Installing older 2.7 versions of 
# pip will not find dependencies needed. This package just creates a /usr/bin/python symlink that points to /usr/bin/python3
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install python-is-python3 && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install python3-pip && \
    /usr/bin/python3 -m pip install -r ${KETTLE_HOME}/docker-entrypoint.d/python_dependencies.txt

# Install Cron
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install cron

# Unzip and install the python plugin for Pentaho Data Integration
RUN /usr/bin/unzip -q ${KETTLE_HOME}/docker-entrypoint.d/python_plugins.zip -d ${KETTLE_HOME}/data-integration/plugins/steps && \
    rm ${KETTLE_HOME}/docker-entrypoint.d/python_plugins.zip

# Change all files copied and unzipped to the pentaho user
RUN chown -R pentaho:pentaho ${KETTLE_HOME} 
RUN chmod +x ${KETTLE_HOME}/scripts/docker-entrypoint.sh

# Switch to the pentaho user
USER pentaho

# We can only add PENTAHO_HOME to the PATH variable now
# as the path gets eveluated - so it must already exist
ENV PENTAHO_HOME=${KETTLE_HOME}/data-integration \
    PATH=${PENTAHO_HOME}:$PATH

# Expose Carte Server
EXPOSE ${CARTE_PORT}

# As we cannot use env variable with the entrypoint and cmd instructions
# we set the working directory here to a convenient location
# We set it to PENTAHO_HOME so we can start carte easily
WORKDIR ${PENTAHO_HOME}


ENTRYPOINT ["../scripts/docker-entrypoint.sh"]

# Run Carte - these parameters are passed to the entrypoint
CMD ["carte.sh", "carte.config.xml"]