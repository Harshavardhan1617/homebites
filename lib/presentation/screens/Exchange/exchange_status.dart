import 'package:flutter/material.dart';
import 'package:home_bites/models/exchange_model.dart';
import 'package:home_bites/services/pocketbase/exchange_stream.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class ExchangeStatus extends StatefulWidget {
  const ExchangeStatus({super.key, this.exchangeID});
  final String? exchangeID;

  @override
  State<ExchangeStatus> createState() => _ExchangeStatusState();
}

class _ExchangeStatusState extends State<ExchangeStatus> {
  late ExchangeStream _exchangeStream;
  late PocketBase _pb;

  @override
  void initState() {
    super.initState();
    _pb = Provider.of<PocketBaseService>(context, listen: false).pb;
    _exchangeStream = ExchangeStream(
      pb: _pb,
      collectionName: 'exchanges',
      recordId: widget.exchangeID!,
    );
  }

  @override
  void dispose() {
    _exchangeStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exchange: ${widget.exchangeID}"),
      ),
      body: StreamBuilder<RecordModel>(
        stream: _exchangeStream.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            ExchangeModel exchange = ExchangeModel.fromMap(snapshot.data!.data);
            return Center(
                child: Text("Exchange Data: ${exchange.toMap().toString()}"));
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
