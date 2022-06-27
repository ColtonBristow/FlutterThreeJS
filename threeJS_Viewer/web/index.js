import { AnimationMixer, WebGLRenderer, AmbientLight, Scene, PerspectiveCamera, Clock, sRGBEncoding, Mesh, } from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls';
import Stats from 'three/examples/jsm/libs/stats.module';
let scene, camera, clock, renderer, mixer, controls, loader, stats, debug;
const setupScene = (_debug) => {
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
        window.Print.postMessage('Scene Created with stats... 10%');
    }
};
const loadCam = (modelURL) => {
    return new Promise((res, rej) => {
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
        (gltf) => {
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
        });
    });
};
const createPerspectiveCamera = (fov, aspectRatio, near, far) => {
    camera = new PerspectiveCamera(fov, aspectRatio != null ? aspectRatio : window.innerWidth / window.innerHeight, near, far);
    globalThis.camera = camera;
    animate();
};
const addAmbientLight = (color, intensity) => {
    const ambient = new AmbientLight(color, intensity);
    scene.add(ambient);
};
const animate = () => {
    requestAnimationFrame(animate);
    var delta = clock.getDelta();
    if (mixer)
        mixer.update(delta);
    if (controls)
        controls.update();
    renderer.render(scene, camera);
    //   if (debug) stats.update();
};
const setCameraPosition = (x, y, z) => {
    camera.position.set(x, y, z);
    controls.update();
};
const setCameraRotation = (x, y, z) => {
    camera.rotation.set(x, y, z);
    controls.update();
};
const setOrbitControls = (polMin, polMax, azMin, azMax, minDistance, maxDistance, enablePan, autoRotateSpeed, autoRotate, enableZoom, c) => {
    controls = new OrbitControls(c !== null && c !== void 0 ? c : camera, renderer.domElement);
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
const setControlsTarget = (x, y, z) => {
    controls.target.set(x, y, z);
    controls.update();
};
const loadModel = (modelUrl, playAnimation) => {
    return new Promise((res, rej) => {
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
        function (gltf) {
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
        });
    });
};
window.setupScene = setupScene;
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
