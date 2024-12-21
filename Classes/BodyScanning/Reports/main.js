// Set current date
function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Helper functions for unit conversions and formatting
function formatHeight(cm) {
    const inches = cm * 0.393701;
    const feet = Math.floor(inches / 12);
    const remainingInches = Math.round(inches % 12);
    return `${feet}'${remainingInches}"`;
}

function formatWeight(kg) {
    const lbs = kg * 2.20462;
    return `${lbs.toFixed(1)} lbs`;
}

function formatMeasurement(cm) {
    const inches = cm * 0.393701;
    return `${inches.toFixed(1)}"`;
}

// Helper function to format age range
function formatAgeRange(data) {
    const ageRange = data.body_fat_percentage_report.percentile.user_age_range;
    return `${ageRange.low}-${ageRange.high} years`;
}

// Function to create percentile segments
function createPercentileSegments(percentileGroups) {
    let html = '';
    percentileGroups.forEach((group, index) => {
        const width = index === 0 ? 5 : 
                     index === 1 ? 5 : 
                     index === 2 ? 10 :
                     index === 3 ? 25 :
                     index === 4 ? 25 :
                     index === 5 ? 15 :
                     index === 6 ? 10 : 5;
        
        html += `<div class="percentile-segment" style="width: ${width}%"></div>`;
    });
    return html;
}

// Function to update a metric's percentile bar
function updatePercentileBar(metricId, report) {
    if (!report || !report.percentile) {
        console.error(`Missing percentile data for ${metricId}`);
        return;
    }
    
    // Find the container for this metric
    const container = document.querySelector(`[data-metric="${metricId}"] .percentile-bar`);
    if (!container) {
        console.error(`Container not found for ${metricId}`);
        return;
    }
    
    // Clear existing segments
    container.innerHTML = '';
    
    // Get percentile groups and sort by range
    const percentileGroups = report.percentile.percentile_groups.sort((a, b) => {
        const aLow = a.range.low || 0;
        const bLow = b.range.low || 0;
        return aLow - bLow;
    });
    
    // Calculate total range for width calculations
    const totalRange = percentileGroups.reduce((max, group) => {
        const high = group.range.high || (group.range.low * 1.2); // Estimate for last group
        return Math.max(max, high);
    }, 0);
    
    // Create segments
    percentileGroups.forEach((group, index) => {
        const div = document.createElement('div');
        div.className = `percentile-segment p${group.value}`;
        
        // Calculate width based on the range
        let width;
        if (index === 0) {
            // First group
            width = ((group.range.high || 0) / totalRange) * 100;
        } else if (index === percentileGroups.length - 1) {
            // Last group
            const previousHigh = percentileGroups[index - 1].range.high;
            width = ((totalRange - previousHigh) / totalRange) * 100;
        } else {
            // Middle groups
            const low = group.range.low || 0;
            const high = group.range.high || totalRange;
            width = ((high - low) / totalRange) * 100;
        }
        
        div.style.width = `${Math.max(width, 5)}%`; // Ensure minimum width of 5%
        container.appendChild(div);
        
        console.log(`Created segment for ${metricId}: value=${group.value}, width=${width}%, range:`, group.range);
    });
    
    // Add marker at user's percentile
    const marker = document.createElement('div');
    marker.className = 'percentile-marker';
    const percentileValue = report.percentile.user_percentile.value;
    marker.style.left = `${percentileValue}%`;
    container.appendChild(marker);
    
    console.log(`Updated percentile bar for ${metricId} with percentile ${percentileValue}`);
}

// Function to update Fat Mass section
function updateFatMassSection(bodyFatPercentage, currentWeight, gender) {
    const fatMass = (bodyFatPercentage / 100) * currentWeight;  // Calculate Fat Mass
    const fatMassElement = document.getElementById('fat-mass-status');
    if (!fatMassElement) return;
    
    fatMassElement.textContent = `${formatWeight(fatMass)}`;
}

// Function to update Body Fat section
function updateBodyFatSection(bodyFatPercentage, gender) {
    const bodyFatElement = document.getElementById('body-fat-status');
    if (!bodyFatElement) return;
    
    bodyFatElement.textContent = `${bodyFatPercentage.toFixed(1)}%`;
}

// Function to update Lean Mass section
function updateLeanMassSection(totalWeight, bodyFatPercentage, gender) {
    const leanMass = totalWeight * (1 - (bodyFatPercentage / 100));
    const leanMassElement = document.getElementById('lean-mass-status');
    if (!leanMassElement) return;
    
    leanMassElement.textContent = `${formatWeight(leanMass)}`;
}

// Function to update Waist-to-Height ratio
function updateWaistToHeightSection(waistToHeightRatio) {
    const waistRatioElement = document.getElementById('waist-ratio-status');
    if (!waistRatioElement) return;
    
    waistRatioElement.textContent = waistToHeightRatio.toFixed(2);
}

// Update the age ranges function to use specific spans
function updateAgeRanges(data) {
    // Update age ranges by metric
    const ageRangeUpdates = [
        { 
            selector: '.lean-mass-age', 
            range: data.lean_mass_report.percentile.user_age_range 
        },
        { 
            selector: '.waist-ratio-age', 
            range: data.waist_to_height_ratio_report.percentile.user_age_range 
        },
        { 
            selector: '.fat-mass-age', 
            range: data.fat_mass_report.percentile.user_age_range 
        },
        { 
            selector: '.age-range:not(.lean-mass-age):not(.waist-ratio-age):not(.fat-mass-age)', 
            range: data.body_fat_percentage_report.percentile.user_age_range 
        }
    ];
    
    ageRangeUpdates.forEach(({ selector, range }) => {
        document.querySelectorAll(selector).forEach(span => {
            span.textContent = `${range.low}-${range.high}`;
        });
    });
}

// Function to update both markers in a metric's bar container
function updateMetricMarkers(metricId, report) {
    // Get the container
    const container = document.querySelector(`[data-metric="${metricId}"]`).closest('.bar-container');
    if (!container) {
        console.error(`Bar container not found for ${metricId}`);
        return;
    }
    
    // Get the value to display based on the metric
    let value;
    switch (metricId) {
        case 'body-fat':
            value = report.body_fat_percentage;
            break;
        case 'fat-mass':
            value = report.fat_mass;
            break;
        case 'lean-mass':
            value = report.lean_mass;
            break;
        case 'waist-ratio':
            value = report.waist_to_height_ratio;
            break;
        default:
            console.error(`Unknown metric: ${metricId}`);
            return;
    }
    
    // Update the gradient bar marker
    const gradientMarker = container.querySelector('.gradient-bar .marker');
    if (gradientMarker) {
        gradientMarker.style.left = `${value}%`;
    }
    
    // Add debug info
    updateDebugInfo(metricId, report);
}

// Function to update the report with new data
function updateHealthReport(data) {
    console.log('Updating health report with data:', data);
    
    try {
        // Update metrics that have percentile bars
        const metrics = [
            { 
                id: 'body-fat', 
                report: data.body_fat_percentage_report,
                label: 'Body Fat Percentage'
            },
            { 
                id: 'fat-mass', 
                report: data.fat_mass_report,
                label: 'Fat Mass'
            },
            { 
                id: 'lean-mass', 
                report: data.lean_mass_report,
                label: 'Lean Mass'
            },
            { 
                id: 'waist-ratio', 
                report: data.waist_to_height_ratio_report,
                label: 'Waist-to-Height Ratio'
            }
        ];
        
        metrics.forEach(metric => {
            if (metric.report) {
                console.log(`Updating ${metric.label} (${metric.id}) percentile bar`);
                try {
                    updatePercentileBar(metric.id, metric.report);
                } catch (error) {
                    console.error(`Error updating ${metric.label} percentile bar:`, error);
                }
            } else {
                console.warn(`Missing report data for ${metric.label} (${metric.id})`);
            }
        });
        
        // Helper function to safely update element text
        function updateElementText(id, value) {
            const element = document.getElementById(id);
            if (element) {
                element.textContent = value;
            } else {
                console.log(`Element with id '${id}' not found`);
            }
        }
        
        // Update demographics
        updateElementText('user-name', data.user.token);
        updateElementText('scan-date', formatDate(data.scan.created_at));
        updateElementText('user-age', `${data.user.age} years`);
        updateElementText('user-gender', data.user.sex);
        updateElementText('user-height', formatHeight(data.user.height * 100));
        updateElementText('user-weight', formatWeight(data.user.weight));
        
        // Update age range if element exists
        updateElementText('age-range', formatAgeRange(data));
        
        // Update measurements
        const waist = data.waist_circumference_report.waist_circumference;
        updateElementText('waist-circumference', formatMeasurement(waist * 100));
        
        // Hide unavailable measurements
        ['neck', 'chest', 'arms', 'thighs', 'calves'].forEach(measurement => {
            const element = document.getElementById(`${measurement}-circumference`);
            if (element && element.parentElement) {
                element.parentElement.style.display = 'none';
            }
        });
        
        // Update body composition with percentile bars and markers
        updateBodyFatSection(data.body_fat_percentage_report.body_fat_percentage, data.user.sex);
        updatePercentileBar('body-fat', data.body_fat_percentage_report);
        updateMetricMarkers('body-fat', data.body_fat_percentage_report);
        
        updateFatMassSection(data.fat_mass_report.fat_mass, data.user.weight, data.user.sex);
        updatePercentileBar('fat-mass', data.fat_mass_report);
        updateMetricMarkers('fat-mass', data.fat_mass_report);
        
        updateLeanMassSection(data.lean_mass_report.lean_mass, data.user.weight, data.user.sex);
        updatePercentileBar('lean-mass', data.lean_mass_report);
        updateMetricMarkers('lean-mass', data.lean_mass_report);
        
        updateWaistToHeightSection(data.waist_to_height_ratio_report.waist_to_height_ratio);
        updatePercentileBar('waist-ratio', data.waist_to_height_ratio_report);
        updateMetricMarkers('waist-ratio', data.waist_to_height_ratio_report);
        
        // Update metabolism section
        const bmr = data.metabolism_report.basal_metabolic_rate;
        const tdee = data.metabolism_report.energy_expenditures.sedentary.maintain_tdee;
        const cutTdee = data.metabolism_report.energy_expenditures.sedentary.cut_tdee;
        const buildTdee = data.metabolism_report.energy_expenditures.sedentary.build_tdee;
        
        updateElementText('bmr-value', Math.round(bmr));
        updateElementText('maintenance-value', Math.round(tdee));
        updateElementText('weight-loss-value', Math.round(cutTdee.minimum));
        updateElementText('muscle-gain-value', Math.round(buildTdee.maximum));
        
        // Update summary
        updateElementText('summary-text', generateSummary(data));

        // Update all age ranges
        updateAgeRanges(data);
        
        // Update the standalone age range spans
        document.querySelectorAll('.age-range').forEach(span => {
            const ageRange = data.body_fat_percentage_report.percentile.user_age_range;
            span.textContent = `${ageRange.low}-${ageRange.high}`;
        });
    } catch (error) {
        console.error('Error updating health report:', error);
    }
}

function generateSummary(data) {
    const bodyFatStatus = data.body_fat_percentage_report.health_label.user_health_label.value;
    const bmr = Math.round(data.metabolism_report.basal_metabolic_rate);
    const recommendation = data.metabolism_report.recommendations.cut === 'RECOMMENDED' ? 
        'fat loss' : 'muscle building';
    
    return `Your body fat percentage is in the ${bodyFatStatus} range. ` +
           `Your basal metabolic rate is ${bmr} calories per day. ` +
           `Based on your metrics, ${recommendation} is recommended.`;
}

// Add debug info update function
function updateDebugInfo(metricId, report) {
    const debugSpan = document.querySelector(`.debug-${metricId}`);
    if (!debugSpan) return;
    
    let value, percentile;
    switch (metricId) {
        case 'body-fat':
            value = report.body_fat_percentage;
            percentile = report.percentile.user_percentile.value;
            break;
        case 'fat-mass':
            value = report.fat_mass;
            percentile = report.percentile.user_percentile.value;
            break;
        case 'lean-mass':
            value = report.lean_mass;
            percentile = report.percentile.user_percentile.value;
            break;
        case 'waist-ratio':
            value = report.waist_to_height_ratio;
            percentile = report.percentile.user_percentile.value;
            break;
    }
    
    debugSpan.textContent = `Gradient bar: ${value}%, Percentile bar: ${percentile}%`;
}
