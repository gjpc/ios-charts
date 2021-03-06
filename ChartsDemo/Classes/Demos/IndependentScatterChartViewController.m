//
//  IndependentScatterChartViewController.m
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 17/3/15.
//  derived from ScatterChart by Gerard J. Cerchio
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

#import "IndependentScatterChartViewController.h"
#import "Charts/Charts-Swift.h"

@interface IndependentScatterChartViewController () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet ScatterChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property (nonatomic ) BOOL areLinesEnabled;
@end

@implementation IndependentScatterChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Independent Scatter Bar Chart";
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleLines", @"label": @"Toggle Lines"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"toggleStartZero", @"label": @"Toggle StartZero"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     ];
    
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.data.highlightEnabled = YES;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.maxVisibleValueCount = 200;
    _chartView.pinchZoomEnabled = YES;
    
    ChartLegend *l = _chartView.legend;
    l.position = ChartLegendPositionRightOfChart;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    
    ChartYAxis *yl = _chartView.leftAxis;
    yl.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    
    _chartView.rightAxis.enabled = NO;
    
    ChartXAxis *xl = _chartView.xAxis;
    xl.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xl.drawGridLinesEnabled = NO;
    
    _sliderX.value = 100.0;
    _sliderY.value = 100.0;
    [self slidersValueChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataCount:(int)count range:(double)range
{
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    
    double nseg = count - 4.0;
    double z = 0.99;                        //Point coordinate affinity
    double dx = count / 2.0 - 2.0;          //Half window height
    double dy = (double)count / 2.0 - 1.0;  //Half window width
    double wx = (double)count / 3.0;        //Ellipse center
    double hy = range / 2.0;                //Ellipse center
    
    double incr = ( count * 0.80 ) / ( count * 0.25 );  // Square pt to pt distance

    double valx,valy;
    for (int i = 0; i < count; i++)
    {
        // circle
        valx = count /2 + count /4 * cos( i / nseg * ( M_PI * 2.0) );
        valy = count /2 + count /4 * sin( i / nseg * ( M_PI * 2.0) );
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue: valy xIndex: valx]];
        
        // Square
        if ( i > count * 0.75 )
        {
            valy = ( count * 0.10 ) - ( i - count ) * incr;
            valx = count * 0.1;
            [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:valy xIndex:valx]];
        }
        else if ( i > count * .50 )
        {
            valx = ( count * 0.90 ) - ( i - count / 2 ) * incr;
            valy = count * 0.9;
            [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:valy xIndex:valx]];
        }
        else if ( i > count * 0.25 )
        {
            valy = ( count * 0.1 ) + ( i - count / 4 ) * incr;
            valx = count * 0.9;
            [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:valy xIndex:valx]];
        }
        else
        {
            valx = ( count * 0.10 ) + i * incr;
            valy = count * 0.1;
            [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:valy xIndex:valx]];
        }
        
        // elipse
        valx = wx * sin((double)i / nseg * ( M_PI * 2.0));
        valy  = hy * cos((double)i / nseg * ( M_PI * 2.0));
        [yVals3 addObject:[[ChartDataEntry alloc] initWithValue: dy + -valy + z xIndex:  (int)(dx + valx + z ) ]];
    }
    
    IndependentScatterChartDataSet *set1 = [[IndependentScatterChartDataSet alloc] initWithYVals:yVals1 label:@"Circle"];
    set1.scatterShape = ScatterShapeSquare;
    [set1 setColor:ChartColorTemplates.colorful[0]];
    IndependentScatterChartDataSet *set2 = [[IndependentScatterChartDataSet alloc] initWithYVals:yVals2 label:@"Square"];
    set2.scatterShape = ScatterShapeCircle;
    [set2 setColor:ChartColorTemplates.colorful[1]];
    IndependentScatterChartDataSet *set3 = [[IndependentScatterChartDataSet alloc] initWithYVals:yVals3 label:@"Elipse"];
    set3.scatterShape = ScatterShapeCross;
    [set3 setColor:ChartColorTemplates.colorful[2]];
    
    set1.scatterShapeSize = 8.0;
    set2.scatterShapeSize = 8.0;
    set3.scatterShapeSize = 8.0;
    
    set1.drawLinesEnabled   = true;
    set1.valueIsIndex       = true;
    
    set2.valueIsIndex       = true;
    set2.drawLinesEnabled   = true;
    
    set3.valueIsIndex       = true;
    set3.drawLinesEnabled   = true;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    
    IndependentScatterChartData *data = [[IndependentScatterChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
    
    _chartView.data = data;
}

- (void)optionTapped:(NSString *)key
{
    if ([key isEqualToString:@"toggleValues"])
    {
        for (ChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawValuesEnabled = !set.isDrawValuesEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleLines"])
    {
        for (IndependentScatterChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawLinesEnabled  = !set.drawLinesEnabled;
            set.drawValuesEnabled = set.drawLinesEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleFilled"])
    {
        for (LineChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawFilledEnabled = !set.isDrawFilledEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleCircles"])
    {
        for (LineChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawCirclesEnabled = !set.isDrawCirclesEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleCubic"])
    {
        for (LineChartDataSet *set in _chartView.data.dataSets)
        {
            set.drawCubicEnabled = !set.isDrawCubicEnabled;
        }
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleHighlight"])
    {
        _chartView.data.highlightEnabled = !_chartView.data.isHighlightEnabled;
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleStartZero"])
    {
        _chartView.leftAxis.startAtZeroEnabled = !_chartView.leftAxis.isStartAtZeroEnabled;
        _chartView.rightAxis.startAtZeroEnabled = !_chartView.rightAxis.isStartAtZeroEnabled;
        
        [_chartView notifyDataSetChanged];
    }
    
    if ([key isEqualToString:@"animateX"])
    {
        [_chartView animateWithXAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"animateY"])
    {
        [_chartView animateWithYAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"animateXY"])
    {
        [_chartView animateWithXAxisDuration:3.0 yAxisDuration:3.0];
    }
    
    if ([key isEqualToString:@"saveToGallery"])
    {
        [_chartView saveToCameraRoll];
    }
    
    if ([key isEqualToString:@"togglePinchZoom"])
    {
        _chartView.pinchZoomEnabled = !_chartView.isPinchZoomEnabled;
        
        [_chartView setNeedsDisplay];
    }
    
    if ([key isEqualToString:@"toggleAutoScaleMinMax"])
    {
        _chartView.autoScaleMinMaxEnabled = !_chartView.isAutoScaleMinMaxEnabled;
        [_chartView notifyDataSetChanged];
    }
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    _sliderTextX.text = [@((int)_sliderX.value + 1) stringValue];
    _sliderTextY.text = [@((int)_sliderY.value) stringValue];
    
    [self setDataCount:(_sliderX.value + 1) range:_sliderY.value];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull )entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
