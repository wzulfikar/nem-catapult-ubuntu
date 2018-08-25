# NEM Catapult Server - Ubuntu 16.04

For those who want to build and run catapult server ***without docker***. Based on:

- https://github.com/nemtech/catapult-server
- https://github.com/44uk/catapult-server-docker

### Usage

- deploy an Ubuntu 16.04 (64 bit) server
- copy the `Makefile` to that server (ie. `~/Makefile`). Or, just use this command and download it from your server:

    ```
    curl -O https://raw.githubusercontent.com/wzulfikar/nem-catapult-ubuntu/master/Makefile
    ```

- login to your server, and go to where you stored above Makefile
- install catapult and its dependencies: `make install`

Once finished, you can start booting your catapult server (refer to `mijin-test.properties` for the config file example):

- generate nemesis block: `make nemesis config=path/to/catapult-config.properties`
- run catapult server: `make up`

---

**DON'T USE THE SAMPLE CONFIG IN PRODUCTION BECAUSE ITS PRIVATE KEY IS PUBLICLY EXPOSED**

---

### Notes

This approach has been tested in 2 different vps (bare metal):

1. **Machine A:** 4vcpu, 8gb RAM, 80 GB SSD: took ~2hrs from build to boot
2. **Machine B:** 8vcpu, 32gb RAM, 220 GB SSD: took ~1hrs from build to boot

CPUs will be working hard during build process. In conclusion, more cpu equals faster build. A 4cpu machine will become fully utilized all the time during the build process.

Once booted up, a catapult-server in its idle state (no tx whatsoever) will take ~2% of CPU usage and ~124mb of RAM.

***That's all folks!***
