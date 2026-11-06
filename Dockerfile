FROM ubuntu:22.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Etc/UTC
ARG TIZEN_STUDIO_VERSION=6.1
ARG EMSDK_VERSION=6.0.5
ARG APP_VERSION=0.1.0

ENV TZ=${TZ}

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        expect \
        git \
        make \
        default-jre \
        python3 \
        unzip \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash builder
USER builder
WORKDIR /home/builder

RUN wget -nv -O tizen-studio-installer.bin \
        "https://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_STUDIO_VERSION}/web-cli_Tizen_Studio_${TIZEN_STUDIO_VERSION}_ubuntu-64.bin" \
    && chmod a+x tizen-studio-installer.bin \
    && ./tizen-studio-installer.bin --accept-license --no-java-check /home/builder/tizen-studio

ENV PATH=/home/builder/tizen-studio/tools/ide/bin:/home/builder/tizen-studio/tools:${PATH}

RUN tizen certificate -a eduke32 -f eduke32 -p 1234 \
    && tizen security-profiles add \
        -n eduke32 \
        -a /home/builder/tizen-studio-data/keystore/author/eduke32.p12 \
        -p 1234 \
    && sed -i 's|/home/builder/tizen-studio-data/keystore/author/eduke32.pwd||' \
        /home/builder/tizen-studio-data/profile/profiles.xml \
    && sed -i 's|/home/builder/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd|tizenpkcs12passfordsigner|' \
        /home/builder/tizen-studio-data/profile/profiles.xml

RUN git clone https://github.com/emscripten-core/emsdk.git /home/builder/emsdk \
    && cd /home/builder/emsdk \
    && ./emsdk install "${EMSDK_VERSION}" \
    && ./emsdk activate "${EMSDK_VERSION}"

COPY --chown=builder:builder . /home/builder/eduke32-tizen
WORKDIR /home/builder/eduke32-tizen

RUN sed -i 's/\r$//' assets/shareware/SHA256SUMS \
    && sha256sum -c assets/shareware/SHA256SUMS

RUN bash -lc 'source /home/builder/emsdk/emsdk_env.sh && \
    cd /home/builder/eduke32-tizen/platform/emscripten && \
    npm ci && npm run build:net'

RUN bash -lc 'source /home/builder/emsdk/emsdk_env.sh && \
    make PLATFORM=EMSCRIPTEN EM_SINGLE_FILE=0 NETDUKE32=1 \
        LDFLAGS="-sWASM_BIGINT=0" -j"$(nproc)"'

RUN cd platform/emscripten \
    && ./node_modules/.bin/esbuild ../../eduke32.js \
        --target=chrome69 --allow-overwrite --log-level=warning \
        --banner:js="window.globalThis || (window.globalThis = window);" \
        --outfile=../../eduke32.js \
    && ./node_modules/.bin/esbuild eduke32-net.js \
        --target=chrome69 --allow-overwrite --log-level=warning \
        --banner:js="window.globalThis || (window.globalThis = window);" \
        --outfile=eduke32-net.js

RUN mkdir -p /home/builder/widget \
    && cp eduke32.js eduke32.wasm eduke32.data /home/builder/widget/ \
    && cp platform/emscripten/index.html \
        platform/emscripten/eduke32-net.js \
        platform/emscripten/grp-manifest.json \
        /home/builder/widget/ \
    && cp platform/tizen/icon.png /home/builder/widget/icon.png \
    && sed -i 's/__BUILD_ID__/tizen/g' /home/builder/widget/index.html \
    && cp platform/tizen/config.xml /home/builder/widget/config.xml \
    && sed -i 's/\r$//' /home/builder/widget/config.xml \
    && printf '%s\n' "${APP_VERSION}" | grep -Eq '^[0-9]+(\.[0-9]+){1,2}$' \
    && sed -i -E "s/^( +version=\")[^\"]*(\")$/\1${APP_VERSION}\2/" \
        /home/builder/widget/config.xml \
    && grep -Fq "version=\"${APP_VERSION}\"" /home/builder/widget/config.xml

RUN echo \
    'set timeout -1\n' \
    'spawn tizen package -t wgt -- /home/builder/widget\n' \
    'expect "Author password:"\n' \
    'send -- "1234\\r"\n' \
    'expect "Yes: (Y), No: (N) ?"\n' \
    'send -- "N\\r"\n' \
    'expect eof\n' \
    | expect \
    && test -f /home/builder/widget/EDuke32.wgt

FROM scratch
COPY --from=build /home/builder/widget/EDuke32.wgt /EDuke32.wgt
