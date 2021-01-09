# Pull base image.
FROM centos/systemd

COPY system /etc/systemd/system/
COPY google-chrome.repo /etc/yum.repos.d/

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; yum -y update all; \
    yum -y install tigervnc-server-minimal novnc google-chrome-stable alsa-firmware alsa-lib alsa-tools-firmware net-tools ; \
    yum -y clean all; rm -rf /var/tmp/* /tmp/* /var/cache/yum/*

RUN /sbin/useradd app;cd /etc/systemd/system/multi-user.target.wants; \
    ln -sf /etc/systemd/system/tgvnc.service tgvnc.service; \    
    ln -sf /etc/systemd/system/chrome.service chrome.service; \
    ln -sf /etc/systemd/system/novnc.service novnc.service;\
    cd /usr/share/novnc; rm -rf index.html

COPY index.html /usr/share/novnc

# Copy Bookmarks and Preferences files
RUN mkdir -p /home/app/.config/google-chrome/Default
COPY Bookmarks /home/app/.config/google-chrome/Default
COPY Preferences /home/app/.config/google-chrome/Default
RUN chown -R app:app /home/app/.config
    
# Define working directory.
WORKDIR /tmp

# Metadata.
LABEL \
      org.label-schema.name="chrome" \
      org.label-schema.description="Docker container for Google-Chrome" \
      org.label-schema.version="Centos7.7"

#EXPOSE 3000 

CMD ["/usr/sbin/init"]