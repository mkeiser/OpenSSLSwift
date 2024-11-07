# How To Create the OpenSSL Package

1. Checkout the source at the version you want (at the time of speaking we use 3.4)
2. The configure, build, and "install" for each of the needed architectures, like this:

    #### macOS Apple Silicon:
    
    - `mkdir macOS_arm64`
    - `cd macOS_arm64 `
    - `../Configure darwin64-arm64 -mmacosx-version-min=13.0 --release --prefix=`pwd`/install`
    - `make`
    - `make install`


    #### macOS Intel:

    - `mkdir macOS_x86_64`
    - `cd macOS_x86_64 `
    - `../Configure darwin64-x86_64 -mmacosx-version-min=13.0 --release --prefix=`pwd`/install`
    - `make`
    - `make install`

    #### iOS:

    - `mkdir ios_arm64`
    - `cd ios_arm64 `
    - `../Configure ios64-xcrun -mios-version-min=16 --release --prefix=`pwd`/install`
    - `make`
    - `make install`

    #### iOS Simulator Apple Silicon:

    - `mkdir ios_sim_arm64`
    - `cd ios_sim_arm64 `
    - `../Configure iossimulator-arm64-xcrun -mios-simulator-version-min=16 --release --prefix=`pwd`/install`
    - `make`
    - `make install`

    #### iOS Simulator Intel:

    - `mkdir ios_sim_x86_64`
    - `cd ios_sim_x86_64 `
    - `../Configure iossimulator-x86_64-xcrun -mios-simulator-version-min=16 --release --prefix=`pwd`/install`
    - `make`
    - `make install`

3. For each arch, combine libcrypto.a and libssl.a into a single lib:

   - `cd install/lib`
   - `xcrun libtool -static -o openssl.a libcrypto.a libssl.a`


4. Create `final` dir for mac, ios, and simulator, and copy the headers:
 
   - `mkdir macOS_final`
   - `cp macOS_arm64/install/include macOS_final`

   - `mkdir iOS_final`
   - `cp ios_arm64/install/include iOS_final`

   - `mkdir iOS_sim_final`
   - `cp ios_sim_arm64/install/include iOS_sim_final`

5. Copy iOS executable:

   - `cp iOS_final/install/lib/openssl.a iOS_final`

6. Create fat binaries for the architectures that require it:

   - `lipo -create macOS_arm64/install/lib/openssl.a macOS_x86_64/install/lib/openssl.a -create macOS_final/openssl.a`
   - `lipo -create ios_sim_arm64/install/lib/openssl.a ios_sim_x86_64/install/lib/openssl.a -create iOS_sim_final/openssl.a`

7. Create xcframework:
   - `xcodebuild -create-xcframework -library macOS_final/libcrypto.a -headers macOS_final/include  -library iOS_final/libcrypto.a  -headers iOS_final/include -library iOS_sim_final/libcrypto.a  -headers iOS_sim_final/include  -output xcframeworks/openssl.xcframework`

8. For all of the frameworks inside the created xcframework, create a module map. It should go into the `Headers` directory for each platform:

	```
	module openssl {
   		umbrella "openssl"
  		exclude header "openssl/asn1_mac.h"
 	 	export *
  		module * { export * }
  	}
   ```

9. Codesign the framework

   `codesign --timestamp -s "Identity" -f /path/to/openssl.xcframework`
   
10. Zip-Compress the framework 

   Result in file `openssl.xcframework.zip`

11. Calculate the hash

	`swift package compute-checksum /path/to/openssl.xcframework.zip`
	
12. Create/Adjust the swift package definition:

		```
        .binaryTarget(
          name: "openssl",
          url: "https://host/openssl.xcframework.zip",
          checksum: "hash from step 11"
         ),
	    ```
    
13. To add the package to `SketchCloudKit`
 
     - close the Sketch project in Xcode
     - Open `SketchCloudKit` in Xcode
     - Add package, at the openssl product to both mac and ios targets
     - Close `SketchCloudKit`, open Sketch project, clean package cache etc..

