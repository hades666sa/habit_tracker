const fs = require('fs');
let code = fs.readFileSync('lib/screens/today/today_screen.dart', 'utf8');

code = code.replace(/    \);\r?\n  Widget _buildSegmentedControl\(bool isDark\) \{/, '    );\n  }\n\n  Widget _buildSegmentedControl(bool isDark) {');

if (!code.endsWith('}\n') && !code.endsWith('}')) {
    code += '\n}\n';
}

fs.writeFileSync('lib/screens/today/today_screen.dart', code);
console.log("Fixed brace issue");
