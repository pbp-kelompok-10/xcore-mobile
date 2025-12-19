import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/models/statistik_entry.dart';
import 'package:xcore_mobile/screens/statistik/statistik_service.dart';

class EditStatistikPage extends StatefulWidget {
  final StatistikEntry statistik;
  final Function() onStatistikUpdated;

  const EditStatistikPage({
    super.key,
    required this.statistik,
    required this.onStatistikUpdated,
  });

  @override
  _EditStatistikPageState createState() => _EditStatistikPageState();
}

class _EditStatistikPageState extends State<EditStatistikPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  
  final TextEditingController _homePassesController = TextEditingController();
  final TextEditingController _awayPassesController = TextEditingController();
  final TextEditingController _homeShotsController = TextEditingController();
  final TextEditingController _awayShotsController = TextEditingController();
  final TextEditingController _homeShotsOnTargetController = TextEditingController();
  final TextEditingController _awayShotsOnTargetController = TextEditingController();
  final TextEditingController _homePossessionController = TextEditingController();
  final TextEditingController _awayPossessionController = TextEditingController();
  final TextEditingController _homeRedCardsController = TextEditingController();
  final TextEditingController _awayRedCardsController = TextEditingController();
  final TextEditingController _homeYellowCardsController = TextEditingController();
  final TextEditingController _awayYellowCardsController = TextEditingController();
  final TextEditingController _homeOffsidesController = TextEditingController();
  final TextEditingController _awayOffsidesController = TextEditingController();
  final TextEditingController _homeCornersController = TextEditingController();
  final TextEditingController _awayCornersController = TextEditingController();

  // Warna dari PROD
  static const Color primaryColor = Color(0xFF4AA69B);
  static const Color accentColor = Color(0xFF34C6B8);
  static const Color scaffoldBgColor = Color(0xFFE8F6F4);
  static const Color lightBgColor = Color(0xFFD1F0EB);
  static const Color darkTextColor = Color(0xFF2C5F5A);
  static const Color mutedTextColor = Color(0xFF6B8E8A);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Initialize controllers dengan data dari statistik
    _homePassesController.text = widget.statistik.homePasses.toString();
    _awayPassesController.text = widget.statistik.awayPasses.toString();
    _homeShotsController.text = widget.statistik.homeShots.toString();
    _awayShotsController.text = widget.statistik.awayShots.toString();
    _homeShotsOnTargetController.text = widget.statistik.homeShotsOnTarget.toString();
    _awayShotsOnTargetController.text = widget.statistik.awayShotsOnTarget.toString();
    _homePossessionController.text = widget.statistik.homePossession.toStringAsFixed(1);
    _awayPossessionController.text = widget.statistik.awayPossession.toStringAsFixed(1);
    _homeRedCardsController.text = widget.statistik.homeRedCards.toString();
    _awayRedCardsController.text = widget.statistik.awayRedCards.toString();
    _homeYellowCardsController.text = widget.statistik.homeYellowCards.toString();
    _awayYellowCardsController.text = widget.statistik.awayYellowCards.toString();
    _homeOffsidesController.text = widget.statistik.homeOffsides.toString();
    _awayOffsidesController.text = widget.statistik.awayOffsides.toString();
    _homeCornersController.text = widget.statistik.homeCorners.toString();
    _awayCornersController.text = widget.statistik.awayCorners.toString();
  }

  @override
  void dispose() {
    _homePassesController.dispose();
    _awayPassesController.dispose();
    _homeShotsController.dispose();
    _awayShotsController.dispose();
    _homeShotsOnTargetController.dispose();
    _awayShotsOnTargetController.dispose();
    _homePossessionController.dispose();
    _awayPossessionController.dispose();
    _homeRedCardsController.dispose();
    _awayRedCardsController.dispose();
    _homeYellowCardsController.dispose();
    _awayYellowCardsController.dispose();
    _homeOffsidesController.dispose();
    _awayOffsidesController.dispose();
    _homeCornersController.dispose();
    _awayCornersController.dispose();
    super.dispose();
  }

  // Metode untuk decrement dengan batasan minimum 0
  void _decrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > 0) {
      setState(() {
        controller.text = (currentValue - 1).toString();
      });
    }
  }

  // Metode untuk increment
  void _incrementValue(TextEditingController controller) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    setState(() {
      controller.text = (currentValue + 1).toString();
    });
  }

  // Metode untuk decrement possession
  void _decrementPossession(TextEditingController controller) {
    double currentValue = double.tryParse(controller.text) ?? 50.0;
    if (currentValue > 0) {
      setState(() {
        controller.text = (currentValue - 1).toStringAsFixed(1);
      });
    }
  }

  // Metode untuk increment possession
  void _incrementPossession(TextEditingController controller) {
    double currentValue = double.tryParse(controller.text) ?? 50.0;
    if (currentValue < 100) {
      setState(() {
        controller.text = (currentValue + 1).toStringAsFixed(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          'Edit Statistik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 16,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Mengupdate statistik...',
                    style: TextStyle(color: mutedTextColor),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match info header
                    _buildMatchHeader(),
                    
                    SizedBox(height: 24),
                    
                    // Statistik Table
                    Text(
                      'Statistik Pertandingan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Statistik items dalam bentuk tabel
                    _buildStatistikTable(),
                    
                    SizedBox(height: 32),
                    
                    // Submit button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMatchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Teams row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.statistik.homeTeam,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
              ),
              
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.statistik.awayTeam,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AWAY',
                      style: TextStyle(
                        fontSize: 10,
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Score row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.statistik.homeScore} - ${widget.statistik.awayScore}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          
          SizedBox(height: 12),
          
          Divider(height: 1, color: mutedTextColor.withOpacity(0.3)),
          SizedBox(height: 8),
          
          // Stadium, Date, Match ID in a more organized layout
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                // Stadium - Full width
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: mutedTextColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.statistik.stadium,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: darkTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Date and Match ID in two columns
                Row(
                  children: [
                    // Date column
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: mutedTextColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: mutedTextColor),
                            SizedBox(width: 6),
                            Text(
                              widget.statistik.matchDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: mutedTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // Match ID column
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 12, color: primaryColor),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'ID: ${widget.statistik.matchId}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikTable() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'STATISTIK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'AWAY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Statistik Rows
          _buildStatistikRow(
            label: 'Passes',
            homeController: _homePassesController,
            awayController: _awayPassesController,
          ),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Total Shots',
            homeController: _homeShotsController,
            awayController: _awayShotsController,
          ),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Shots on Target',
            homeController: _homeShotsOnTargetController,
            awayController: _awayShotsOnTargetController,
          ),
          _buildDivider(),
          
          // Ball Possession Row (special)
          _buildPossessionRow(),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Yellow Cards',
            homeController: _homeYellowCardsController,
            awayController: _awayYellowCardsController,
          ),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Red Cards',
            homeController: _homeRedCardsController,
            awayController: _awayRedCardsController,
          ),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Offside',
            homeController: _homeOffsidesController,
            awayController: _awayOffsidesController,
          ),
          _buildDivider(),
          
          _buildStatistikRow(
            label: 'Corners',
            homeController: _homeCornersController,
            awayController: _awayCornersController,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikRow({
    required String label,
    required TextEditingController homeController,
    required TextEditingController awayController,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkTextColor,
              ),
            ),
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Decrement Button
                GestureDetector(
                  onTap: () => _decrementValue(homeController),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Home Value
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: homeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true, // Make it read-only since we use buttons
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Home Increment Button
                GestureDetector(
                  onTap: () => _incrementValue(homeController),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: mutedTextColor,
              ),
            ),
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Away Decrement Button
                GestureDetector(
                  onTap: () => _decrementValue(awayController),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Away Value
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: awayController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Away Increment Button
                GestureDetector(
                  onTap: () => _incrementValue(awayController),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: whiteColor,
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

  Widget _buildPossessionRow() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ball Possession (%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: darkTextColor,
            ),
          ),
          
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Home Decrement Button
                        GestureDetector(
                          onTap: () => _decrementPossession(_homePossessionController),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Home Value
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: TextFormField(
                            controller: _homePossessionController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              suffixText: '%',
                              suffixStyle: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            readOnly: true,
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Home Increment Button
                        GestureDetector(
                          onTap: () => _incrementPossession(_homePossessionController),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mutedTextColor,
                  ),
                ),
              ),
              
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Away Decrement Button
                        GestureDetector(
                          onTap: () => _decrementPossession(_awayPossessionController),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: accentColor.withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: accentColor,
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Away Value
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          child: TextFormField(
                            controller: _awayPossessionController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              suffixText: '%',
                              suffixStyle: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            readOnly: true,
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // Away Increment Button
                        GestureDetector(
                          onTap: () => _incrementPossession(_awayPossessionController),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AWAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Total possession indicator
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Possession:',
                  style: TextStyle(
                    fontSize: 12,
                    color: darkTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTotalPossessionColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getTotalPossession().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getTotalPossession() == 100.0 ? Colors.white : Colors.red,
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

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: mutedTextColor.withOpacity(0.2),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: primaryColor.withOpacity(0.5),
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: whiteColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'MENGUPDATE...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'UPDATE STATISTIK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getTotalPossession() {
    final home = double.tryParse(_homePossessionController.text) ?? 0;
    final away = double.tryParse(_awayPossessionController.text) ?? 0;
    return home + away;
  }

  Color _getTotalPossessionColor() {
    final total = _getTotalPossession();
    if (total == 100) return primaryColor;
    if (total > 100) return Colors.orange;
    return Colors.red;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validasi possession total = 100%
      final totalPossession = _getTotalPossession();
      
      if (totalPossession != 100.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Total possession harus 100% (Saat ini: ${totalPossession.toStringAsFixed(1)}%)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      try {
        final Map<String, dynamic> formData = {
          'match': widget.statistik.matchId,
          'home_passes': int.tryParse(_homePassesController.text) ?? 0,
          'away_passes': int.tryParse(_awayPassesController.text) ?? 0,
          'home_shots': int.tryParse(_homeShotsController.text) ?? 0,
          'away_shots': int.tryParse(_awayShotsController.text) ?? 0,
          'home_shots_on_target': int.tryParse(_homeShotsOnTargetController.text) ?? 0,
          'away_shots_on_target': int.tryParse(_awayShotsOnTargetController.text) ?? 0,
          'home_possession': double.tryParse(_homePossessionController.text) ?? 0.0,
          'away_possession': double.tryParse(_awayPossessionController.text) ?? 0.0,
          'home_red_cards': int.tryParse(_homeRedCardsController.text) ?? 0,
          'away_red_cards': int.tryParse(_awayRedCardsController.text) ?? 0,
          'home_yellow_cards': int.tryParse(_homeYellowCardsController.text) ?? 0,
          'away_yellow_cards': int.tryParse(_awayYellowCardsController.text) ?? 0,
          'home_offsides': int.tryParse(_homeOffsidesController.text) ?? 0,
          'away_offsides': int.tryParse(_awayOffsidesController.text) ?? 0,
          'home_corners': int.tryParse(_homeCornersController.text) ?? 0,
          'away_corners': int.tryParse(_awayCornersController.text) ?? 0,
        };
        
        print('=== MENGUPDATE STATISTIK ===');
        print('Data: $formData');
        
        final success = await StatistikService.updateStatistik(
          context, 
          widget.statistik.matchId, 
          formData
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statistik berhasil diupdate'),
              backgroundColor: primaryColor,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            )
          );
          widget.onStatistikUpdated();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Gagal mengupdate statistik'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            )
          );
        }
      } catch (e) {
        print('❌ Error updating statistik: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}