import {
  AnimationMixer,
  WebGLRenderer,
  AmbientLight,
  Scene,
  PerspectiveCamera,
  Clock,
  sRGBEncoding,
  Mesh,
  ColorRepresentation,
} from 'three';
import { GLTFLoader, GLTF } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import Stats from 'three/examples/jsm/libs/stats.module';

let scene: Scene,
  camera: PerspectiveCamera,
  clock: Clock,
  renderer: WebGLRenderer,
  mixer: AnimationMixer,
  controls: OrbitControls,
  loader: GLTFLoader,
  stats: HTMLDivElement,
  debug: boolean;

const setupScene = (_debug: boolean) => {
  scene = new Scene();
  camera = new PerspectiveCamera();
  clock = new Clock();

  renderer = new WebGLRenderer({
    alpha: true,
    antialias: true,
  });

  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.shadowMap.enabled = true;
  renderer.physicallyCorrectLights = true;
  renderer.outputEncoding = sRGBEncoding;
  renderer.setClearColor(0xcccccc);

  document.body.appendChild(renderer.domElement);

  if (debug) {
    const s = Stats();
    document.body.appendChild(s.dom);
    stats = s.dom;

    (window as any).Print.postMessage('Scene Created with stats... 10%');
  }
};

const loadCam = (modelURL: string) => {
  return new Promise<GLTF>((res, rej) => {
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
      modelURL,
      // called when the resource is loaded
      (gltf: GLTF) => {
        //setCamera(gltf.cameras[0]);
        //camera = gltf.cameras[0];
        animate();

        res(gltf);
      },
      // called while loading is progressing
      (xhr) => {
        console.log((xhr.loaded / xhr.total) * 100 + '% loaded');
        globalThis.onObjectLoading((xhr.loaded / xhr.total) * 100);
      },
      // called when loading has errors
      (error) => {
        console.log('An error happened', error);
        globalThis.onLoadError(error);
        rej(error);
      }
    );
  });
};

const createPerspectiveCamera = (
  fov: number,
  aspectRatio: number,
  near: number,
  far: number
) => {
  camera = new PerspectiveCamera(
    fov,
    aspectRatio != null ? aspectRatio : window.innerWidth / window.innerHeight,
    near,
    far
  );
  globalThis.camera = camera;
  animate();
};

const addAmbientLight = (color: ColorRepresentation, intensity: number) => {
  const ambient = new AmbientLight(color, intensity);
  scene.add(ambient);
};

const animate = () => {
  requestAnimationFrame(animate);
  var delta = clock.getDelta();
  if (mixer) mixer.update(delta);
  if (controls) controls.update();
  renderer.render(scene, camera);
  //   if (debug) stats.update();
};

const setCameraPosition = (x: number, y: number, z: number) => {
  camera.position.set(x, y, z);
  controls.update();
};

const setCameraRotation = (x: number, y: number, z: number) => {
  camera.rotation.set(x, y, z);
  controls.update();
};

const setOrbitControls = (
  polMin: number,
  polMax: number,
  azMin: number,
  azMax: number,
  minDistance: number,
  maxDistance: number,
  enablePan: boolean,
  autoRotateSpeed: number,
  autoRotate: boolean,
  enableZoom: boolean,
  c: PerspectiveCamera
) => {
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

  controls.update();
  animate();
  globalThis.controls = controls;
};

const setControlsTarget = (x: number, y: number, z: number) => {
  controls.target.set(x, y, z);
  controls.update();
};

const loadModel = (modelUrl: string, playAnimation: boolean) => {
  return new Promise<GLTF>((res, rej) => {
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
      modelUrl,
      // called when the resource is loaded
      function (gltf: GLTF) {
        if (playAnimation) {
          mixer = new AnimationMixer(gltf.scene);
          const action = mixer.clipAction(gltf.animations[0]);
          action.play();
        }
        gltf.scene.traverse(function (node) {
          if (node instanceof Mesh) {
            node.castShadow = true;
            node.material.depthWrite = !node.material.transparent;
          }
        });
        scene.add(gltf.scene);

        res(gltf);
        if (debug) {
          globalThis.Print.postMessage('loaded the following: ' + modelUrl);
        }
      },
      // called while loading is progressing
      (xhr) => {
        console.log((xhr.loaded / xhr.total) * 100 + '% loaded');
        globalThis.onObjectLoading((xhr.loaded / xhr.total) * 100);
      },
      // called when loading has errors
      (error) => {
        console.log('An error happened', error);
        globalThis.onLoadError('on loading error: ' + error);
        rej(error);
      }
    );
  });
};

(window as any).setupScene = setupScene;
globalThis.setOrbitControls = setOrbitControls;
globalThis.setControlsTarget = setControlsTarget;
globalThis.loadModel = loadModel;
globalThis.addAmbientLight = addAmbientLight;
globalThis.loadCam = loadCam;
globalThis.setCameraPosition = setCameraPosition;
globalThis.setCameraRotation = setCameraRotation;
globalThis.createPerspectiveCamera = createPerspectiveCamera;

//! TODO:
//?  window.setupLights = setupLights;
//? window.setupDebug = setupDebug
