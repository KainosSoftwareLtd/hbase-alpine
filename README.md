# HBase Alpine Docker Image
## What is it?
This is a containerized version of HBase running on Alpine and the AdoptOpenJDK OpenJDK 8 JRE. This docker image has been created for the ONS project, and due to restrictions on external network usage, it ships with all the binaries required to build it.

## How is the image built?
The base image used is `alpine`, we then install and configure the AdoptOpenJDK distribution of the OpenJDK 8 JRE as well as other dependencies such as bash and jruby. To avoid the need for access to an outside network, offline versions of these alpine packages are copied and installed during the build.

To meet GitHub's maximum recommended file size limits, the hbase-bin archive has been split into 50MB parts. During the build we copy these to the image, concatenating the archive and extracting its contents to the /opt directory. We then remove unnecessary files to reduce the image size (docs, readme, etc).

Finally we add our entrypoint script to the image.

## How do I build the image?
You can build the image by running the following command in the `data/hbase-alpine` directory:
```
docker build . -t hbase-alpine-ons
```

## What happens when the container is run?
The HBase configuration files need a hostname to be specified. While this could be done when building the image, it is possible that the user will want to specify a different hostname when running the container. To solve this, the entrypoint script will create the HBase configuration files at runtime using the container's hostname.

If a user has mounted a volume at the container's `/data` directory, then the script will recognize this and print to the terminal that data will be persisted here. If not, the script will create a `/data` directory within the container and report that HBase data will not be persisted on the host.

Finally, the HBase `HBase master` and `HBase REST` servers are started.

Logs of stdout and stderr for these are saved to the `/data/logs` directory.

The state of the HBase database is saved to `/data/hbase`

N.B. As neither the Data or Dev teams are using the thrift interface for HBase, we have not started this service. If you do require a thrift server you will need to add this line to the end of the `entrypoint.sh` script before building the image:
```
hbase thrift start > $LOGS_DIR/thrift.log 2>&1
```

## How do I run the container?:
After building the image, you can run the container with the following command:
```
docker run --name=hbase-docker -h hbase-docker -p 2181:2181 -p 8080:8080 -p 17876:16010 -p 16000:16000 -p 16020:16020 -d hbase-alpine-ons
```
If you want to persist data on the host you can add a parameter to mount a volume like so:
```
-v $PWD/data:/data
```

## Can I use a different hostname for the container?
Yes, just pass a different hostname in the -h argument when running the container. The entrypoint script will update the HBase configuration to reflect this.
```
-h a-different-hostname
```

## Can I bind to different host ports?
You can safely bind most of the internal container ports to different host ports during the docker run:
```
-p 2182:2181
```
The only exception to this is the regionserver port. The container's internal regionserver port (16020 by default) and the host's need to be identical.

To achieve this edit the entrypoint script, replacing the value of hbase.regionserver.port (16020) in the hbase-site.xml heredoc with the desired new port. Then rebuild the image and run passing the new binding as an argument as above.
