# NEM Catapult Server - Ubuntu

For those who want to build and run catapult server ***without docker***. Tested on Ubuntu 16.04 and Ubuntu 18.04. Based on:

- https://github.com/nemtech/catapult-server
- https://github.com/44uk/catapult-server-docker

### Usage

1. deploy an Ubuntu 16.04 or 18.04 (64 bit) server
2. copy the `Makefile` to that server (ie. `~/Makefile`), or use this command to download it from your server:

    ```
    curl -O https://raw.githubusercontent.com/wzulfikar/nem-catapult-ubuntu/master/Makefile
    ```

3. login to your server, and go to where you stored above Makefile
4. install catapult and its dependencies: `make install`

Once finished, your `/opt` directory will look like this:

```
▸ /opt
  ▾ catapult
    ▾ catapult-server
      ▾ bin
        [catapult binaries]
    ▾ resources
      [resources-related config files]
    ▾ tools
      [tools-related config files]
    ▾ data
      [catapult-related data]
    ▾ seed
      [catapult-related data]
```

### Booting Up The Catapult

1. open the sample config file at `/opt/catapult/tools/nemgen/resources/mijin-test.properties`
2. adjust the value of `cppFile` and `binDirectory` to become like this:

  ```
  [output]
  cppFile = /opt/catapult-server/tests/test/core/mocks/MockMemoryBasedStorage_data.h
  binDirectory = /opt/catapult/data
  ```

3. generate nemesis block. as an example, we'll use the sample config from catapult repo: `make nemesis config=/opt/catapult/tools/nemgen/resources/mijin-test.properties`
4. run catapult server: `make up`

### Notes

- The order of packages installed in `Makefile` has been put in such a way that packages with dependencies will be installed first (ie. some scripts need to use cmake, mongoc needs `boost` to be available, etc.). This means that changing the order of installation might break the script.

- Catapult seems to require a specific version of packages. Changing the version of packages might break the build process

- This approach has been tested in 4 different vps (bare metal):

  1. **Machine A:** Ubuntu 16.04, 4 cores @ 2.4 GHz, 8gb RAM, 80 GB SSD: took ~2hrs from build to boot
  2. **Machine B:** Ubuntu 16.04, 4 cores (8 cores with hyperthreading) @ 3.5 GHz, 32gb RAM, 220 GB SSD: took ~1hrs from build to boot
  3. **Machine C:** Ubuntu 18.04, 4 cores (8 cores with hyperthreading) @ 3.5 GHz, 32gb RAM, 220 GB SSD: took ~30min from build to boot
  4. **Machine D:** Ubuntu 18.04, 24 cores (48 cores with hyperthreading) @ 2.2 GHz, 64gb RAM, 960 GB SSD: took ~40min from build to boot

- CPUs will be working hard during build process. In conclusion, more cpu equals faster build. A 4cpu machine will become fully utilized all the time during the build process. Once booted up, the catapult-server, in its idle state (no tx whatsoever) will take ~2% of CPU usage and ~124mb of RAM.

***That's all, folks!***
