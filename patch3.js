const fs = require('fs');
let file = fs.readFileSync('frontend/apps/mobile-app/lib/features/dashboard/presentation/pages/mandal_details_screen.dart', 'utf8');

file = file.replace(/border: InputBorder.none,/g, 'border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),');

fs.writeFileSync('frontend/apps/mobile-app/lib/features/dashboard/presentation/pages/mandal_details_screen.dart', file);
console.log('Patched mandal_details_screen.dart successfully');
