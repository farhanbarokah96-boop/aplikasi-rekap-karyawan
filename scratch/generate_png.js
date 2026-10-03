const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('Generating PNG logo...');
// Check if any tools available or write pure PNG
