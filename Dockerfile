FROM python:3.6-stretch

# --install-suggests clang
RUN apt-get update && \
  apt-get install -y \
    build-essential \
    cmake \
    git \
    make \
    libzip-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip  --no-cache-dir install cython pytest
RUN pip3 --no-cache-dir install cython pytest

RUN mkdir -p /project/pyxlsxio
WORKDIR /project
RUN git clone https://github.com/RobertWSmith/pyxlsxio.git

WORKDIR /project/pyxlsxio
RUN git submodule update --init
RUN python setup.py build_ext --inplace

ENTRYPOINT ["pytest"]
