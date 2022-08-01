pub_get: 
	cd threeJS_Viewer \
	echo "root directory"; \
	flutter pub get; \
	cd example; \
	echo "example directory"; \
	flutter pub get

pod_install:
	cd threeJS_Viewer \
	echo "running pod install"; \
	cd example/ios; \
	pod install; \
	echo "done";

pub_clean:
	cd threeJS_Viewer \
	echo "running pub clean"; \
	cd example/; \
	flutter clean; \
	echo "done";