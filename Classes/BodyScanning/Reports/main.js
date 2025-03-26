// Add this at the top of main.js
console.log("main.js loaded");

// Helper functions
function formatDate(dateString) {
  if (!dateString) return "--";
  const date = new Date(dateString);
  return date.toLocaleDateString();
}

function formatHeight(cm) {
  if (!cm) return "--";
  const inches = cm * 0.393701;
  const feet = Math.floor(inches / 12);
  const remainingInches = Math.round(inches % 12);
  return `${feet}'${remainingInches}"`;
}

function formatWeight(kg) {
  if (!kg) return "--";
  const lbs = kg * 2.20462;
  return `${Math.round(lbs)} lbs`;
}

function updateHealthReport(data) {
  if (!data || !data.user) {
    console.warn("No health report data available");
    return;
  }

  console.log("Updating health report with:", data);
  updateDemographics(data);
}

function updateDemographics(data) {
  if (!data || !data.user) {
    console.warn("No user data available", data);
    return;
  }

  console.log("Updating demographics with:", {
    token: data.user.token,
    age: data.user.age,
    sex: data.user.sex,
    height: data.user.height,
    weight: data.user.weight,
    scanDate: data.scan.created_at,
  });

  // Update user info with fallbacks
  document.getElementById("user-name").textContent = data.user.token || "--";
  document.getElementById("scan-date").textContent = formatDate(data.scan.created_at) || "--";
  document.getElementById("user-age").textContent = `${data.user.age} years` || "--";
  document.getElementById("user-gender").textContent = data.user.sex || "--";
  document.getElementById("user-height").textContent = formatHeight(data.user.height * 100) || "--";
  document.getElementById("user-weight").textContent = formatWeight(data.user.weight) || "--";

  // Log what was actually set
  console.log("Demographics elements updated:", {
    name: document.getElementById("user-name").textContent,
    date: document.getElementById("scan-date").textContent,
    age: document.getElementById("user-age").textContent,
    gender: document.getElementById("user-gender").textContent,
    height: document.getElementById("user-height").textContent,
    weight: document.getElementById("user-weight").textContent,
  });
}

function updateMeasurements(measurements) {
  console.log("updateMeasurements called with:", measurements);

  if (!measurements) {
    console.warn("No measurements data available");
    return;
  }

  // Helper function to format measurements from meters to inches
  const formatMeasurement = (value) => {
    if (value == null) {
      console.log("Null value received for measurement");
      return "--";
    }
    const metersToInches = 39.3701;
    const formatted = `${(value * metersToInches).toFixed(1)}"`;
    console.log(`Formatting ${value}m to ${formatted}`);
    return formatted;
  };

  // Calculate and log bilateral averages
  const armsAverage =
    measurements.midArmLeftFit && measurements.midArmRightFit
      ? (measurements.midArmLeftFit + measurements.midArmRightFit) / 2
      : measurements.midArmLeftFit || measurements.midArmRightFit;
  console.log("Arms average:", armsAverage);

  const thighsAverage =
    measurements.thighLeftFit && measurements.thighRightFit
      ? (measurements.thighLeftFit + measurements.thighRightFit) / 2
      : measurements.thighLeftFit || measurements.thighRightFit;
  console.log("Thighs average:", thighsAverage);

  const calvesAverage =
    measurements.calfLeftFit && measurements.calfRightFit
      ? (measurements.calfLeftFit + measurements.calfRightFit) / 2
      : measurements.calfLeftFit || measurements.calfRightFit;
  console.log("Calves average:", calvesAverage);

  // Log all measurements before updating
  console.log("Raw measurements:", {
    neck: measurements.neckFit,
    chest: measurements.chestFit,
    waist: measurements.waistFit,
    arms: armsAverage,
    thighs: thighsAverage,
    calves: calvesAverage,
  });

  const measurementElements = {
    "neck-circumference": measurements.neckFit,
    "chest-circumference": measurements.chestFit,
    "waist-circumference": measurements.waistFit,
    "arms-circumference": armsAverage,
    "thighs-circumference": thighsAverage,
    "calves-circumference": calvesAverage,
  };

  // Update each measurement in the DOM with logging
  Object.entries(measurementElements).forEach(([id, value]) => {
    const element = document.getElementById(id);
    if (element) {
      const formattedValue = formatMeasurement(value);
      console.log(`Updating ${id} with value: ${formattedValue}`);
      element.textContent = formattedValue;
    } else {
      console.error(`Element not found: ${id}`);
      // Log the current DOM structure to help debug
      console.log(
        "Current measurements section:",
        document.querySelector(".measurements-section")?.innerHTML
      );
    }
  });

  console.log("Measurements update completed");
}

// Make functions available globally
window.updateHealthReport = updateHealthReport;
window.updateMeasurements = updateMeasurements;

// Add DOM ready handler
document.addEventListener("DOMContentLoaded", function () {
  console.log("main.js DOM ready");
  // Verify functions are available
  console.log("updateHealthReport available:", typeof window.updateHealthReport === "function");
  console.log("updateMeasurements available:", typeof window.updateMeasurements === "function");
});
