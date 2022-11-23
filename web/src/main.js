import {
  AnimationMixer,
  WebGLRenderer,
  AmbientLight,
  Scene,
  PerspectiveCamera,
  Clock,
  sRGBEncoding,
  GridHelper,
  AxesHelper,
} from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import Stats from 'three/examples/jsm/libs/stats.module';
import * as TWEEN from '@tweenjs/tween.js'

let scene, camera, clock, renderer, mixer, controls, loader, stats, debug;

let shouldDemoControls = true;

const setupScene = (_debug) => {
  debug = _debug ?? false;
  scene = new Scene();
  clock = new Clock();

  renderer = new WebGLRenderer({ alpha: true, antialias: true });

  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.shadowMap.enabled = true;
  renderer.physicallyCorrectLights = true;
  renderer.outputEncoding = sRGBEncoding;
  renderer.setClearColor(0xcccccc, 0);

  document.body.appendChild(renderer.domElement);

  if (debug) {
    stats = Stats();
    document.body.appendChild(stats.dom);

    console.log('Scene Created with stats... 10%');
  }

  return true;
};

const createPerspectiveCamera = (fov, aspectRatio, near, far) => {
  console.log('createPerspectiveCamera() called');
  camera = new PerspectiveCamera(
    fov,
    aspectRatio != null ? aspectRatio : window.innerWidth / window.innerHeight,
    near,
    far,
  );
  window.camera = camera;
  animate();
};

const setOrbitControls = (
  polMin,
  polMax,
  azMin,
  azMax,
  minDistance,
  maxDistance,
  enablePan,
  autoRotateSpeed,
  autoRotate,
  enableZoom,
  c
) => {
  console.log('setOrbitControls() called');
  shouldDemoControls = autoRotate;
  controls = new OrbitControls(c ?? camera, renderer.domElement);
  controls.target.set(0, 0, 0);

  controls.minPolarAngle = polMin != null ? polMin : -Infinity;
  controls.maxPolarAngle = polMax != null ? polMax : Infinity;
  controls.minAzimuthAngle = azMin != null ? azMin : -Infinity;
  controls.maxAzimuthAngle = azMax != null ? azMax : -Infinity;

  controls.minDistance = minDistance != null ? minDistance : -Infinity;
  controls.maxDistance = maxDistance != null ? maxDistance : Infinity;
  controls.enablePan = enablePan != null ? enablePan : true;
  controls.autoRotateSpeed = autoRotateSpeed != null ? autoRotateSpeed : 0;
  controls.autoRotate = autoRotate != null ? autoRotate : false;
  controls.enableZoom = enableZoom != null ? enableZoom : true;

  controls.addEventListener('start', function () {
    controls.autoRotate = false;
    shouldDemoControls = false;
  });

  controls.addEventListener("end", function() {
    console.log(`x: ${camera.position.x}, y: ${camera.position.y} , z: ${camera.position.z}`);
  });

  controls.update();
  animate();
  setCameraPosition(0, 0, 30);
  window.controls = controls;
};

const setControlsTarget = (x, y, z) => {
  console.log('setControlsTarget() called');
  controls.target.set(x, y, z);
  controls.update();
};

const addGridHelper = () => {
  console.log('addGridHelper() called');
  var helper = new GridHelper(100, 100);
  helper.rotation.x = Math.PI / 2;
  helper.material.opacity = 1;
  helper.material.transparent = false;
  scene.add(helper);

  var axis = new AxesHelper(1000);
  scene.add(axis);
};

const setCameraPosition = (x, y, z) => {
  console.log('setCameraPosition() called');
  camera.position.set(x, y, z);
  controls.update();
};

const setCameraRotation = (x, y, z) => {
  console.log('setCameraRotation() called');
  camera.rotation.set(x, y, z);
  controls.update();
};

const loadModel = (modelUrl, playAnimation, scale) => {
  console.log('loadModel() called');
  new Promise((res, rej) => {
    // Instantiate a loader
    loader = new GLTFLoader();

    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('decoder/');
    dracoLoader.setDecoderConfig({ type: 'js' });
    loader.setDRACOLoader(dracoLoader);
    //TODO: add cross origin and header control

    // Load a glTF resource
    loader.load(
      // resource URL
      'https://cors-anywhere-ey3dyle52q-uc.a.run.app/' + modelUrl,
      // called when the resource is loaded
      function (gltf) {
        if (playAnimation) {
          mixer = new AnimationMixer(gltf.scene);
          const action = mixer.clipAction(gltf.animations[0]);
          action.play();
        }
        gltf.scene.traverse(function (node) {
          if (node.isMesh) {
            node.castShadow = true;
            node.material.depthWrite = !node.material.transparent;
          }
        });
        gltf.scene.scale.set(scale, scale, scale);
        scene.add(gltf.scene);

        res(gltf);
        if (debug) {
          console.log('loaded the following: ' + modelUrl);
        }
      },
      // called while loading is progressing
      (xhr) => {
        var percentLoaded = (xhr.loaded / xhr.total) * 100


        console.log(percentLoaded + '% loaded');
        //window.ModelLoading.postMessage((xhr.loaded / xhr.total) * 100);
        window.flutter_inappwebview.callHandler('ModelLoading', percentLoaded) * 1.0;
      },
      // called when loading has errors
      (error) => {
        //window.onLoadError('on loading error: ' + error);

        //window.Error.postMessage(error)
        window.flutter_inappwebview.callHandler('Error', percentLoaded);

        rej(error);
      }
    );
  });
};

const loadCam = (modelUrl) => {
  console.log('loadCam() called');
  new Promise((res, rej) => {
    // Instantiate a loader
    loader = new GLTFLoader();

    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('decoder/');
    dracoLoader.setDecoderConfig({ type: 'js' });
    loader.setDRACOLoader(dracoLoader);

    // Load a glTF resource
    loader.load(
      // resource URL
      modelUrl,
      // called when the resource is loaded
      (gltf) => {
        setCamera(gltf.cameras[0]);

        animate();

        res(gltf);
      },
      // called while loading is progressing
      (xhr) => {
        var percentLoaded = (xhr.loaded / xhr.total) * 100
        //window.onObjectLoading(percentLoaded);

        //! send loading to flutter to be parsed
        //window.CameraLoading.postMessage(percentLoaded)
        window.flutter_inappwebview.callHandler('CameraLoading', percentLoaded);

      },
      // called when loading has errors
      (error) => {
        //window.onLoadError(error);
        rej(error);

       //window.Error.postMessage(error)
        window.flutter_inappwebview.callHandler('Error', percentLoaded);
      }
    );
  });
};

const addAmbientLight = (color, intensity) => {
  console.log('addAmbientLight() called');
  const ambient = new AmbientLight(color, intensity);
  scene.add(ambient);
};

const animate = () => {
  //console.log('animate() called');
  setTimeout(function () {
    requestAnimationFrame(animate);
  }, 65);

  var delta = clock.getDelta();
  if (mixer) mixer.update(delta);
  if (controls) controls.update();
  TWEEN.update();
  renderer.render(scene, camera);
  if (debug) stats.update();
  if (camera && controls && shouldDemoControls) {
    camera.position.z += 0.03;
  }
};

const resetCameraControls = (autoRotate, yOffset) => {
  console.log("resetCameraControls() called");
  controls.dispose();
  controls = new OrbitControls(camera, renderer.domElement);
  controls.target.set(0, yOffset, 0);
  if (yOffset) controls.target.set(0, yOffset, 0);
  else controls.target.set(0, 0, 0);
  controls.enablePan = true;
  controls.minDistance = 3;
  controls.maxDistance = 500;

  controls.addEventListener('start', () => {
    shouldPreviewControls = autoRotate ?? false;
  });

  controls.update();
  controls.saveState();
};

const tweenCamera = (targetX, targetY, targetZ, duration, yOffset) => {
  console.log("tweenCamera() called");
  shouldDemoControls = false;
  controls.autoRotate = false;
  var target = controls.target.clone();
  var tweenTarget = new TWEEN.Tween(target).to({ x: 0, y: (yOffset ? yOffset : 0), z: 0 }, 2000).easing(TWEEN.Easing.Quartic.In).onUpdate(function () {
    controls.target.set(target.x, target.y, target.z);
    controls.update();
  }).onStart(function () {
    var tweenCamera = new TWEEN.Tween(camera.position).to({ x: targetX, y: targetY, z: targetZ }, duration).easing(TWEEN.Easing.Quartic.In);
    tweenCamera.start();
  });

  tweenTarget.start();
}

window.tweenCamera = tweenCamera;
window.setupScene = setupScene;
window.setOrbitControls = setOrbitControls;
window.setControlsTarget = setControlsTarget;
window.loadModel = loadModel;
window.addAmbientLight = addAmbientLight;
window.loadCam = loadCam;
window.resetCameraControls = resetCameraControls;
window.addGridHelper = addGridHelper;
window.setCameraPosition = setCameraPosition;
window.setCameraRotation = setCameraRotation;
window.createPerspectiveCamera = createPerspectiveCamera;
