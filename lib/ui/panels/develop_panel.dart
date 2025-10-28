import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/knobs/knob.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/util/layout.dart';

/// Develop panel with exposure, contrast, and tone adjustments
class DevelopPanel extends StatelessWidget {
  const DevelopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorState>(
      builder: (context, editorState, child) {
        return SafePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEVELOP',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Knob grid
              KnobGrid(
                children: ParamDefinitions.develop.map((paramDef) {
                  return ParameterKnob(
                    paramDef: paramDef,
                    value: editorState.getParamValue(paramDef.name),
                    onChanged: (value) => editorState.updateParam(paramDef.name, value),
                    onReset: () => editorState.resetParam(paramDef.name),
                    editorState: editorState,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}