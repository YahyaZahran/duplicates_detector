import 'dart:io';

import 'package:duplicates_detector/app/pages/results_page/index.dart';
import 'package:duplicates_detector/detector/parser.dart';
import 'package:duplicates_detector/detector/solver.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:reactive_file_picker/reactive_file_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final form = fb.group({
    "type": FormControl<String>(validators: [Validators.required]),
    "file": FormControl<String>(validators: [
      Validators.required,
      (control) {
        if (control.isNull ||
            control.value.endsWith(".xls") ||
            control.value.endsWith(".xlsx")) return null;

        return {
          "Excel files are allowed only": true,
        };
      }
    ])
  });

  void submit() async {
    final path = form.control("file").value;
    final type = form.control("type").value;
    final bytes = await File(path).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    late Sheet alreadySheet, creationSheet;
    if (type == "Single") {
      alreadySheet = excel.sheets.entries.first.value;
      creationSheet = excel.sheets.entries.first.value;
    } else {
      alreadySheet = excel.sheets["PA Already exist"]!;
      creationSheet = excel.sheets["PA to be created"]!;
    }
    final parser = StringToDetectorInputParser();
    final solver = Solver();

    final creation = parser.parseSheet(creationSheet);
    final already = StringToDetectorInputParser().parseSheet(alreadySheet);
    final errors = solver.findErrors(creation);
    final res =
        solver.solve(creation, already, skipSameLineIds: type == "Single");
    final warnings = solver.getAllWarnings(creation, already,
        skipSameLineIds: type == "Single");

    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ResultsPage(
          params: ResultsPageParams(
            duplicates: res,
            warnings: warnings,
            errors: errors,
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Duplicates Detector App",
        ),
        centerTitle: true,
      ),
      body: ReactiveForm(
        formGroup: form,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Select what kind of file u have",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ReactiveDropdownField(
                      formControlName: "type",
                      items: const [
                        DropdownMenuItem(
                          value: "Single",
                          child: Text("Single Sheet"),
                        ),
                        DropdownMenuItem(
                          value: "Two",
                          child: Text("Two Sheets"),
                        ),
                      ],
                      onChanged: (va) {},
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 27,
              ),
              Text(
                "Select the input file",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(
                height: 12,
              ),
              ReactiveFilePicker("file"),
              const Divider(
                height: 27,
              ),
              const SizedBox(
                height: 24,
              ),
              Center(
                child: Builder(builder: (context) {
                  return SizedBox(
                    width: 200,
                    child: ReactiveFormConsumer(
                      builder: (context, formGroup, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                          ),
                          onPressed: formGroup.invalid
                              ? null
                              : () async {
                                  if (ReactiveForm.of(context)!.valid) {
                                    submit();
                                  } else {
                                    ReactiveForm.of(context)!
                                        .markAllAsTouched();
                                  }
                                },
                          child: Text("Start"),
                        );
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReactiveFilePicker extends ReactiveFormField {
  final String formFiledName;
  ReactiveFilePicker(this.formFiledName)
      : super(
          formControlName: formFiledName,
          builder: (state) => FilePickerWidget(
            state: state,
          ),
        );
}

class FilePickerWidget extends StatefulWidget {
  final ReactiveFormFieldState state;
  const FilePickerWidget({
    super.key,
    required this.state,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  @override
  Widget build(BuildContext context) {
    final shouldShowError =
        (widget.state.control.invalid && widget.state.control.touched);
    return Container(
      decoration: BoxDecoration(
        border: shouldShowError
            ? Border.all(
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.state.value != null
              ? _buildFileSelected()
              : _buildNoFileSelected(),
          if (shouldShowError) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.state.control.errors.entries.first.key.toString(),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildNoFileSelected() {
    return InkWell(
      onTap: () async {
        final res = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          dialogTitle: "Select input file",
        );
        if (res?.files.isNotEmpty ?? false) {
          final file = res!.files.first;
          widget.state.control.value = file.path;
          widget.state.control.markAsTouched();
        }
      },
      child: Ink(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * .3,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/xls.png",
              width: 200,
              height: MediaQuery.of(context).size.height * .15,
            ),
            const SizedBox(height: 12),
            Text(
              "Select your Excel file",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelected() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/xls.png",
                width: 200,
                height: MediaQuery.of(context).size.height * .15,
              ),
            ],
          ),
          Expanded(
            child: Text(widget.state.value!),
          ),
          InkWell(
            onTap: () {
              setState(() {
                widget.state.control.reset();
              });
            },
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
