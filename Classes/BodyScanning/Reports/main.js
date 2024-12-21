import * as THREE from 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@r128/build/three.module.js';
import { OBJLoader } from 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@r128/examples/jsm/loaders/OBJLoader.js';
import { OrbitControls } from 'https://cdn.jsdelivr.net/gh/mrdoob/three.js@r128/examples/jsm/controls/OrbitControls.js';

// Initialize variables
const users = ['User1', 'User2', 'User3', 'User4', 'User5', 'User6'];
const userDropdownMenu = document.getElementById('userDropdownMenu');
const userDropdownButton = document.getElementById('userDropdown');

// Auto-rotation settings
let autoRotateSpeed = 0.005;  // Speed of rotation
let isAutoRotating = true;   // Flag to control auto-rotation

// Populate the dropdown dynamically with user options from data.json
users.forEach(user => {
    const userFolderPath = `assets/${user}/`; 
    const jsonFilePath = `${userFolderPath}data.json`;

    fetch(jsonFilePath)
        .then(response => response.json())
        .then(data => {
            const listItem = document.createElement('li');
            const link = document.createElement('a');
            link.classList.add('dropdown-item');
            link.textContent = data.userName;
            link.href = '#';
            link.dataset.user = user;
            listItem.appendChild(link);
            userDropdownMenu.appendChild(listItem);

            // Add event listener for selecting a user
            link.addEventListener('click', function (event) {
                event.preventDefault();
                const selectedUser = event.target.dataset.user;
                loadUserData(selectedUser);
            });
        })
        .catch(error => {
            console.error(`Error loading data.json for ${user}:`, error);
        });
});

// Set current date
function formatDate() {
    const date = new Date();
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return date.toLocaleDateString(undefined, options);
}
document.getElementById('current-date').textContent = formatDate();

// Initialize cameras, controls, and renderers for both views
let camera1, camera2, controls1, controls2, scene1, scene2, renderer1, renderer2;

function clearScene(scene) {
    while (scene.children.length > 0) {
        scene.remove(scene.children[0]);
    }
}

function syncCameras(sourceCamera, targetCamera) {
    targetCamera.position.copy(sourceCamera.position);
    targetCamera.rotation.copy(sourceCamera.rotation);
    targetCamera.zoom = sourceCamera.zoom;
    targetCamera.updateProjectionMatrix();
}

function initCameraAndControls(container, camera, controls, syncWithOtherControls) {
    camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    camera.position.z = 5;

    controls = new OrbitControls(camera, container);
    controls.enablePan = false;
    controls.enableZoom = true;
    controls.enableRotate = true;

    controls.addEventListener('change', () => {
        syncWithOtherControls();
    });

    return { camera, controls };
}

function initAvatar(containerId, objPath, texturePath, scene, renderer, camera) {
    const container = document.getElementById(containerId);

    clearLights(scene);

    const ambientLight = new THREE.AmbientLight(0x404040, 4);
    scene.add(ambientLight);

    const textureLoader = new THREE.TextureLoader();
    const texture = textureLoader.load(texturePath);

    const loader = new OBJLoader();
    loader.load(objPath, function (object) {
        object.traverse(function (child) {
            if (child.isMesh) {
                child.material.map = texture;
            }
        });

        object.position.y = -2.7;
        object.scale.set(3, 3, 3);
        object.rotation.x = Math.PI / 120;
        object.rotation.z = Math.PI / 2;

        scene.add(object);
        renderer.render(scene, camera);
    });

    window.addEventListener('resize', () => {
        const width = container.clientWidth;
        const height = container.clientHeight;
        renderer.setSize(width, height);
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
    });
}

function clearLights(scene) {
    const lights = scene.children.filter(child => child.isLight);
    lights.forEach(light => scene.remove(light));
}

// Function to update Fat Mass section
function updateFatMassSection(bodyFatPercentage, currentWeight, gender) {
    const fatMass = (bodyFatPercentage / 100) * currentWeight;  // Calculate Fat Mass
    const fatMassElement = document.getElementById('fat-mass');
    fatMassElement.textContent = `${fatMass.toFixed(2)} lbs`;

    const fatMassStatus = document.getElementById('fat-mass-status'); // Status label

    document.querySelectorAll('#very-low-fm-bar, #low-fm-bar, #healthy-fm-bar, #high-fm-bar, #unhealthy-fm-bar').forEach(bar => {
        bar.style.backgroundColor = 'lightgray';
    });

    if (gender === 'male') {
        if (fatMass < currentWeight * 0.05) {
            document.getElementById('very-low-fm-bar').style.backgroundColor = '#659D55';
            fatMassStatus.textContent = "Very low";
        } else if (fatMass >= currentWeight * 0.05 && fatMass < currentWeight * 0.10) {
            document.getElementById('low-fm-bar').style.backgroundColor = '#289E6C';
            fatMassStatus.textContent = "Low";
        } else if (fatMass >= currentWeight * 0.10 && fatMass < currentWeight * 0.20) {
            document.getElementById('healthy-fm-bar').style.backgroundColor = '#289E6C';
            fatMassStatus.textContent = "Healthy";
        } else if (fatMass >= currentWeight * 0.20 && fatMass < 0.25 * currentWeight) {
            document.getElementById('high-fm-bar').style.backgroundColor = '#D97D46';
            fatMassStatus.textContent = "High";
        } else {
            document.getElementById('unhealthy-fm-bar').style.backgroundColor = '#FF0000';
            fatMassStatus.textContent = "Unhealthy";
        }
    } else if (gender === 'female') {
        if (fatMass < currentWeight * 0.13) {
            document.getElementById('very-low-fm-bar').style.backgroundColor = '#659D55';
            fatMassStatus.textContent = "Very low";
        } else if (fatMass >= currentWeight * 0.13 && fatMass < currentWeight * 0.18) {
            document.getElementById('low-fm-bar').style.backgroundColor = '#289E6C';
            fatMassStatus.textContent = "Low";
        } else if (fatMass >= currentWeight * 0.18 && fatMass < currentWeight * 0.28) {
            document.getElementById('healthy-fm-bar').style.backgroundColor = '#289E6C';
            fatMassStatus.textContent = "Healthy";
        } else if (fatMass >= currentWeight * 0.28 && fatMass < 0.32 * currentWeight) {
            document.getElementById('high-fm-bar').style.backgroundColor = '#D97D46';
            fatMassStatus.textContent = "High";
        } else {
            document.getElementById('unhealthy-fm-bar').style.backgroundColor = '#FF0000';
            fatMassStatus.textContent = "Unhealthy";
        }
    }
}

// Function to update Lean Mass section
function updateLeanMassSection(currentWeight, bodyFatPercentage, gender) {
    const leanMass = currentWeight - (currentWeight * bodyFatPercentage / 100);  // Calculate Lean Mass
    const leanMassElement = document.getElementById('lean-mass');
    leanMassElement.textContent = `${leanMass.toFixed(2)} lbs`;

    const leanMassStatus = document.getElementById('lean-mass-status'); // Status label

    document.querySelectorAll('#low-lm-bar, #min-lm-bar, #healthy-lm-bar, #high-lm-bar, #unhealthy-lm-bar').forEach(bar => {
        bar.style.backgroundColor = 'lightgray';
    });

    if (gender === 'male') {
        if (leanMass <= currentWeight - (currentWeight * 0.25)) {
            document.getElementById('unhealthy-lm-bar').style.backgroundColor = '#A05F5F';
            leanMassStatus.textContent = "Very Low";
        } else if (leanMass <= currentWeight - (currentWeight * 0.20) && leanMass < currentWeight - (currentWeight * 0.25)) {
            document.getElementById('high-lm-bar').style.backgroundColor = '#A05F5F';
            leanMassStatus.textContent = "Low";
        } else if (leanMass <= currentWeight - (currentWeight * 0.10) && leanMass < currentWeight - (currentWeight * 0.20)) {
            document.getElementById('healthy-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        } else if (leanMass <= currentWeight - (currentWeight * 0.05) && leanMass < currentWeight - (currentWeight * 0.10)) {
            document.getElementById('min-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        } else {
            document.getElementById('low-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        }
    } else if (gender === 'female') {
        if (leanMass <= currentWeight - (currentWeight * 0.32)) {
            document.getElementById('unhealthy-lm-bar').style.backgroundColor = '#A05F5F';
            leanMassStatus.textContent = "Very Low";
        } else if (leanMass <= currentWeight - (currentWeight * 0.28) && leanMass < currentWeight - (currentWeight * 0.32)) {
            document.getElementById('high-lm-bar').style.backgroundColor = '#A05F5F';
            leanMassStatus.textContent = "Low";
        } else if (leanMass <= currentWeight - (currentWeight * 0.18) && leanMass < currentWeight - (currentWeight * 0.28)) {
            document.getElementById('healthy-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        } else if (leanMass <= currentWeight - (currentWeight * 0.13) && leanMass < currentWeight - (currentWeight * 0.18)) {
            document.getElementById('min-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        } else {
            document.getElementById('low-lm-bar').style.backgroundColor = '#659D55';
            leanMassStatus.textContent = "Healthy";
        }
    }
}

// Function to update Body Fat section
function updateBodyFatSection(bodyFatPercentage, gender) {
    const bodyFatElement = document.getElementById('body-fat-percentage');
    bodyFatElement.textContent = `${bodyFatPercentage} %`;

    const bodyFatStatus = document.getElementById('body-fat-status'); // Status label

    document.querySelectorAll('#low-bar, #min-bar, #healthy-bar, #high-bar, #unhealthy-bar').forEach(bar => {
        bar.style.backgroundColor = 'lightgray';
    });

    if (gender === 'male') {
        if (bodyFatPercentage < 5) {
            document.getElementById('low-bar').style.backgroundColor = '#659D55';
            bodyFatStatus.textContent = "Low";
        } else if (bodyFatPercentage >= 5 && bodyFatPercentage < 10) {
            document.getElementById('min-bar').style.backgroundColor = '#289E6C';
            bodyFatStatus.textContent = "Minimum";
        } else if (bodyFatPercentage >= 10 && bodyFatPercentage < 20) {
            document.getElementById('healthy-bar').style.backgroundColor = '#289E6C';
            bodyFatStatus.textContent = "Healthy";
        } else if (bodyFatPercentage >= 20 && bodyFatPercentage < 25) {
            document.getElementById('high-bar').style.backgroundColor = '#D97D46';
            bodyFatStatus.textContent = "High";
        } else {
            document.getElementById('unhealthy-bar').style.backgroundColor = '#FF0000';
            bodyFatStatus.textContent = "Unhealthy";
        }
    } else if (gender === 'female') {
        if (bodyFatPercentage < 13) {
            document.getElementById('low-bar').style.backgroundColor = '#659D55';
            bodyFatStatus.textContent = "Low";
        } else if (bodyFatPercentage >= 13 && bodyFatPercentage < 18) {
            document.getElementById('min-bar').style.backgroundColor = '#289E6C';
            bodyFatStatus.textContent = "Minimum";
        } else if (bodyFatPercentage >= 18 && bodyFatPercentage < 28) {
            document.getElementById('healthy-bar').style.backgroundColor = '#289E6C';
            bodyFatStatus.textContent = "Healthy";
        } else if (bodyFatPercentage >= 28 && bodyFatPercentage < 32) {
            document.getElementById('high-bar').style.backgroundColor = '#D97D46';
            bodyFatStatus.textContent = "High";
        } else {
            document.getElementById('unhealthy-bar').style.backgroundColor = '#FF0000';
            bodyFatStatus.textContent = "Unhealthy";
        }
    }
}

// Function to update Waist-to-Height ratio
function updateWaistToHeightSection(waistCircumference, height) {
    const waistToHeightRatio = waistCircumference / height;
    const waistRatioElement = document.getElementById('waist-to-height-ratio');
    waistRatioElement.textContent = waistToHeightRatio.toFixed(2);

    const waistToHeightRatioStatus = document.getElementById('waist-ratio-status'); // Status label

    document.querySelectorAll('#in-range-bar, #wht-high-bar, #very-high-bar').forEach(bar => {
        bar.style.backgroundColor = 'lightgray';
    });

    if (waistToHeightRatio <= 0.50) {
        document.getElementById('in-range-bar').style.backgroundColor = '#659D55';
        waistToHeightRatioStatus.textContent = "In Range";
    } else if (waistToHeightRatio >= 0.50 && waistToHeightRatio <= 0.59) {
        document.getElementById('wht-high-bar').style.backgroundColor = '#EAAF00';
        waistToHeightRatioStatus.textContent = "High";
    } else {
        document.getElementById('very-high-bar').style.backgroundColor = '#FF0000';
        waistToHeightRatioStatus.textContent = "Very High";
    }
}

// Function to load user data
function loadUserData(user) {
    const userFolderPath = `assets/${user}/`;
    const jsonFilePath = `${userFolderPath}data.json`;

    fetch(jsonFilePath)
        .then(response => response.json())
        .then(data => {
            clearScene(scene1);
            clearScene(scene2);

            document.getElementById('current-weight').textContent = `${data.currentWeight} lbs`;
            document.getElementById('target-weight').textContent = `${data.targetWeight} lbs`;
            document.getElementById('summary-text').textContent = data.summaryText;

            updateBodyFatSection(data.bodyFatPercentage, data.gender);
            updateFatMassSection(data.bodyFatPercentage, data.currentWeight, data.gender);
            updateLeanMassSection(data.currentWeight, data.bodyFatPercentage, data.gender);
            updateWaistToHeightSection(data.waistCircumference, data.height);

            initAvatar('today-avatar', `${userFolderPath}today-avatar.obj`, `${userFolderPath}texture.png`, scene1, renderer1, camera1);
            initAvatar('future-avatar', `${userFolderPath}future-avatar.obj`, `${userFolderPath}texture.png`, scene2, renderer2, camera2);

            userDropdownButton.textContent = data.userName;
        })
        .catch(error => {
            console.error('Error loading user data:', error);
        });
}

// Initialize the application
function initialize() {
    const container1 = document.getElementById('today-avatar');
    renderer1 = new THREE.WebGLRenderer({ antialias: true });
    renderer1.setClearColor(0x060606);
    renderer1.setSize(container1.clientWidth, container1.clientHeight);
    container1.appendChild(renderer1.domElement);
    scene1 = new THREE.Scene();

    const container2 = document.getElementById('future-avatar');
    renderer2 = new THREE.WebGLRenderer({ antialias: true });
    renderer2.setClearColor(0x060606);
    renderer2.setSize(container2.clientWidth, container2.clientHeight);
    container2.appendChild(renderer2.domElement);
    scene2 = new THREE.Scene();

    ({ camera: camera1, controls: controls1 } = initCameraAndControls(container1, camera1, controls1, () => syncCameras(camera1, camera2)));
    ({ camera: camera2, controls: controls2 } = initCameraAndControls(container2, camera2, controls2, () => syncCameras(camera2, camera1)));

    loadUserData('User1');


// Function to handle auto-rotation for both scenes
function applyAutoRotation() {
    if (isAutoRotating) {
        scene1.rotation.y -= autoRotateSpeed;
        scene2.rotation.y -= autoRotateSpeed;
    }
}

// Modify controls to stop auto-rotation on interaction
controls1.addEventListener('start', () => {
    isAutoRotating = false;
});
controls2.addEventListener('start', () => {
    isAutoRotating = false;
});

    function animate() {
        requestAnimationFrame(animate);
        applyAutoRotation(); // Apply auto-rotation
        controls1.update();
        controls2.update();
        renderer1.render(scene1, camera1);
        renderer2.render(scene2, camera2);
    }
    animate();
}

// Run the initialize function
initialize();
