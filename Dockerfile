FROM jupyter-base
WORKDIR /workspace
# letp dependencies and development tools
RUN apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran file binutils \
        musl-dev python3-dev openblas-dev && \
    apk add libstdc++ openblas && \
    \
    #ln -s locale.h /usr/include/xlocale.h && \
    \
    pip install numpy && \
    pip install pandas && \
    pip install scipy && \
    pip install scikit-learn && \
    \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    \
    #rm /usr/include/xlocale.h && \
    \
    apk del .build-dependencies


# Add pycddlib and cvxopt with GLPK
RUN cd /tmp && \
    apk add --no-cache \
        --virtual=.build-dependencies \
        gcc make file binutils \
        musl-dev python3-dev gmp-dev suitesparse-dev openblas-dev && \
    apk add gmp suitesparse && \
    \
    pip install cython && \
    pip install pycddlib && \
    pip uninstall --yes cython && \
    \
    wget "ftp://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz" && \
    tar xzf "glpk-4.65.tar.gz" && \
    cd "glpk-4.65" && \
    ./configure --disable-static && \
    make -j4 && \
    make install-strip && \
    CVXOPT_BLAS_LIB=openblas CVXOPT_LAPACK_LIB=openblas CVXOPT_BUILD_GLPK=1 pip install --global-option=build_ext --global-option="-I/usr/include/suitesparse" cvxopt && \
    \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    \
    apk del .build-dependencies && \
rm -rf /tmp/*
RUN pip3 install matplotlib
RUN pip3 install json-tricks


RUN apk add freetype-dev libpng-dev cabal ghc texlive-full
RUN cabal update
RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN cabal install pandoc pandoc-citeproc
RUN ln -s /usr/bin/mktexlsr /usr/local/lib/perl5/site_perl/mktexlsr.pl
ENV PATH="/root/.cabal/bin:${PATH}"


COPY letp/ /workspace/letp/
RUN pip3 install -e /workspace/letp


COPY capstone.ipynb /workspace

