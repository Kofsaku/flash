#!/usr/bin/env python3
import re

# Read the original mock_data_service file
with open('/tmp/original_mock_data_service.dart', 'r') as f:
    content = f.read()

# Find the _initializeLevels method
init_levels_match = re.search(r'void _initializeLevels\(\) \{(.*?)\n  \}', content, re.DOTALL)
if init_levels_match:
    levels_content = init_levels_match.group(1)
    
    # Find each level definition
    level_patterns = [
        (r'junior_high_1', r'Level\(\s*id: \'junior_high_1\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'junior_high_1_data.dart'),
        (r'junior_high_2', r'Level\(\s*id: \'junior_high_2\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'junior_high_2_data.dart'),
        (r'junior_high_3', r'Level\(\s*id: \'junior_high_3\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'junior_high_3_data.dart'),
        (r'high_school_1', r'Level\(\s*id: \'high_school_1\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'high_school_1_data.dart'),
        (r'high_school_2', r'Level\(\s*id: \'high_school_2\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'high_school_2_data.dart'),
        (r'high_school_3', r'Level\(\s*id: \'high_school_3\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'high_school_3_data.dart'),
        (r'university_toeic', r'Level\(\s*id: \'university_toeic\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'university_toeic_data.dart'),
        (r'practical_english', r'Level\(\s*id: \'practical_english\'.*?totalExamples: \d+,\s*completedExamples: \d+,\s*\)', 'practical_english_data.dart'),
    ]
    
    for level_id, pattern, filename in level_patterns:
        # Find the level definition
        level_match = re.search(pattern, content, re.DOTALL)
        if level_match:
            level_def = level_match.group(0)
            
            # Create the function name
            func_name = ''.join(word.capitalize() for word in level_id.split('_')) + 'Level'
            func_name = 'get' + func_name
            
            # Create the file content
            file_content = f"""import '../models/level.dart';

{func_name}() {{
  return {level_def};
}}
"""
            
            # Write to file
            with open(f'lib/data/{filename}', 'w') as f:
                f.write(file_content)
            
            print(f"Created {filename}")
        else:
            print(f"Could not find level definition for {level_id}")

print("Level extraction complete")