import 'package:clipboard/clipboard.dart';
import 'package:duplicates_detector/detector/solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/hybrid.dart';
import 'package:yaru/yaru.dart';

class ResultsPageParams {
  final List<Duplicate> duplicates;
  final List<WarningEntry> warnings;
  final List<ErrorEntry> errors;
  ResultsPageParams({
    required this.duplicates,
    required this.warnings,
    required this.errors,
  });
}

class ResultsPage extends StatelessWidget {
  final ResultsPageParams params;

  const ResultsPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Results"),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Duplicates (${params.duplicates.length})",
              ),
              Tab(
                text: "Warnings (${params.warnings.length})",
              ),
              Tab(
                text:
                    "Errors (${params.errors.where((element) => element.attributes.isNotEmpty).length})",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DuplicatesView(params: params),
            _WarningsView(params: params),
            _ErrorsView(params: params),
          ],
        ),
      ),
    );
  }
}

class _ErrorsView extends StatelessWidget {
  const _ErrorsView({
    super.key,
    required this.params,
  });

  final ResultsPageParams params;

  @override
  Widget build(BuildContext context) {
    if (params.errors.isEmpty) return const _NoDataFoundWidget();
    return ListView.builder(
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(
            "Line Id = ${params.errors[index].line.id}",
          ),
          subtitle:
              Text("${params.errors[index].attributes.length} Attribute(s)"),
          expandedAlignment: Alignment.centerLeft,
          children: params.errors[index].attributes
              .map(
                (e) => ListTile(
                  title: Text(
                    "👉 ${e.name}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
              .toList(),
        );
      },
      itemCount: params.errors.length,
    );
  }
}

class _WarningsView extends StatelessWidget {
  const _WarningsView({
    super.key,
    required this.params,
  });

  final ResultsPageParams params;

  @override
  Widget build(BuildContext context) {
    if (params.warnings.isEmpty) return const _NoDataFoundWidget();
    return ListView.builder(
      itemBuilder: (context, index) {
        return ExpansionTile(
          title: Text(
            "Line Id = ${params.warnings[index].line.id}",
          ),
          subtitle:
              Text("${params.warnings[index].attributes.length} Attribute(s)"),
          expandedAlignment: Alignment.centerLeft,
          children: params.warnings[index].attributes
              .map(
                (e) => ListTile(
                  title: Text(
                    "👉 ${e.name}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
              .toList(),
        );
      },
      itemCount: params.warnings.length,
    );
  }
}

class _DuplicatesView extends StatelessWidget {
  const _DuplicatesView({
    super.key,
    required this.params,
  });

  final ResultsPageParams params;

  @override
  Widget build(BuildContext context) {
    if (params.duplicates.isEmpty) return const _NoDataFoundWidget();
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor:
            MaterialStatePropertyAll(Theme.of(context).secondaryHeaderColor),
        columns: const [
          DataColumn(
            label: Expanded(
              child: Center(
                child: Text("Creation"),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Center(
                child: Text("Exist"),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Center(
                child: Text("Action"),
              ),
            ),
          ),
        ],
        rows: [
          ...params.duplicates.map(
            (e) => DataRow(
              cells: [
                DataCell(Center(
                  child: Text(
                    e.firstLine.id,
                  ),
                )),
                DataCell(Center(
                  child: Text(
                    e.secondLine.id,
                  ),
                )),
                DataCell(
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            children: [
                              SimpleDialogOption(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Creation Line ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .warningColor,
                                              ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            FlutterClipboard.controlC(
                                                e.firstLine.toString());
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("Copied"),
                                                duration:
                                                    Duration(milliseconds: 200),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.copy,
                                            color:
                                                Theme.of(context).warningColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    HighlightView(
                                      e.firstLine.toString(),
                                      padding: const EdgeInsets.all(12),
                                      language: "ada",
                                      theme: hybridTheme,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SimpleDialogOption(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Already Exist Line ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .warningColor,
                                              ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            FlutterClipboard.controlC(
                                                e.secondLine.toString());
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("Copied"),
                                                duration:
                                                    Duration(milliseconds: 200),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.copy,
                                            color:
                                                Theme.of(context).warningColor,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    HighlightView(
                                      e.secondLine.toString(),
                                      padding: const EdgeInsets.all(12),
                                      language: "ada",
                                      theme: hybridTheme,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      child: Text("Show"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDataFoundWidget extends StatelessWidget {
  const _NoDataFoundWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/icons/man.png"),
        const SizedBox(height: 25),
        Text(
          "No Data found",
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
