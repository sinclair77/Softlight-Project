import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softlightstudio/ui/knobs/knob.dart';
import 'package:softlightstudio/editor/editor_state.dart';
import 'package:softlightstudio/util/layout.dart';

/// Color panel with temperature and tint adjustments
class ColorPanel extends StatelessWidget {
  const ColorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorState>(
      builder: (context, editorState, child) {
        return SafePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COLOR',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              // Knob grid
              KnobGrid(
                children: ParamDefinitions.color.map((paramDef) {
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