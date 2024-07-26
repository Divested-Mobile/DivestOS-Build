1. Build image

```sh
./build-image-{podman,docker}.sh
```

2. Run container

required arguments:
- $1 - path where android build will end up

```sh
mkdir android
./run-image-{podman,docker}.sh "$(pwd)/Builds"
```

3. Proceed with build

Either proceed manually (https://divestos.org/pages/build#init) or use the scripts:

  a. Setup divestos-build

    ```sh
    # $1: version
    ./phase-1.sh "20.0" |& tee phase-1.log
    ```

  b. Choose your options (optional)

    ```sh
    nano DivestOS/Scripts/init.sh
    ```

  c. Update description (optional)

    ```sh
    nano DivestOS/Scripts/Generate_Signing_Keys.sh
    ```

  d. Add vendor blobs

    ```sh
    githuborg=""  # <-- put the correct github organization here
    sed -i "/github/s/\[COLOUR IN THE LINES\]/$githuborg/g" DivestOS/Build/LineageOS-20.0/.repo/local_manifests/local_manifest.xml
    gitlaborg=""  # <-- put the correct gitlab organization here
    sed -i "/gitlab/s/\[COLOUR IN THE LINES\]/$gitlaborg/g" DivestOS/Build/LineageOS-20.0/.repo/local_manifests/local_manifest.xml
    ```

  e. Download and Build

    ```sh
    # $1: version
    # $2: device
    ./phase-2.sh "20.0" "sailfish" |& tee phase-2.log
    ```

    Note: To read logs with rendered color codes, you can use `less -r phase-2.log`.

4. Proceed with Installation

The flashable builds are now located in the build directory path you assigned above and you're ready for [installation](https://divestos.org/pages/bootloader).
