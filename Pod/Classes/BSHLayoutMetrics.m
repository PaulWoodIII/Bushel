/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHLayoutMetrics.h"

CGFloat const BSHRowHeightVariable = -1000;
CGFloat const BSHRowHeightRemainder = -1001;
CGFloat const BSHRowHeightPartition = -1002;
CGFloat const BSHRowHeightWaterFall = -1003;
CGFloat const BSHRowHeightDefault = 44;

@implementation BSHLayoutSupplementaryMetrics

- (instancetype)init
{
	return (self = [self initWithSupplementaryViewKind:nil]);
}

- (instancetype)initWithSupplementaryViewKind:(NSString *)kind
{
	self = [super init];
	if (!self) return nil;
	_supplementaryViewKind = [kind copy];
	return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	BSHLayoutSupplementaryMetrics *item = [[BSHLayoutSupplementaryMetrics allocWithZone:zone] initWithSupplementaryViewKind:_supplementaryViewKind];
	if (!item)
		return nil;
	
	item->_reuseIdentifier = [_reuseIdentifier copy];
	item->_height = _height;
	item->_hidden = _hidden;
	item->_shouldPin = _shouldPin;
	item->_visibleWhileShowingPlaceholder = _visibleWhileShowingPlaceholder;
	item->_supplementaryViewClass = _supplementaryViewClass;
	item->_createView = _createView;
	item->_configureView = _configureView;
	item->_backgroundColor = _backgroundColor;
	item->_selectedBackgroundColor = _selectedBackgroundColor;
	item->_padding = _padding;
	item->_zIndex = _zIndex;
	return item;
}

- (NSString *)reuseIdentifier
{
    if (_reuseIdentifier)
        return _reuseIdentifier;

    return NSStringFromClass(_supplementaryViewClass);
}

- (void)configureWithBlock:(BSHLayoutSupplementaryItemConfigurationBlock)block
{
    NSParameterAssert(block != nil);

    if (!_configureView) {
        self.configureView = block;
        return;
    }

    // chain the old with the new
    BSHLayoutSupplementaryItemConfigurationBlock oldConfigBlock = _configureView;
    self.configureView = ^(UICollectionReusableView *view, id dataSource, NSIndexPath *indexPath) {
        oldConfigBlock(view, dataSource, indexPath);
        block(view, dataSource, indexPath);
    };
}

@end

@implementation BSHLayoutSectionMetrics {
	NSMutableArray *_supplementaryViews;
    struct {
        BOOL showsSectionSeparatorWhenLastSection;
        BOOL backgroundColor;
        BOOL selectedBackgroundColor;
        BOOL separatorColor;
        BOOL sectionSeparatorColor;
    } _flags;
}

+ (instancetype)defaultMetrics
{
    BSHLayoutSectionMetrics *metrics = [[self alloc] init];
    metrics.rowHeight = BSHRowHeightDefault;
    return metrics;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    BSHLayoutSectionMetrics *metrics = [[BSHLayoutSectionMetrics allocWithZone:zone] init];
    if (!metrics)
        return nil;

    metrics->_rowHeight = _rowHeight;
    metrics->_padding = _padding;
    metrics->_separatorInsets = _separatorInsets;
    metrics->_backgroundColor = _backgroundColor;
    metrics->_selectedBackgroundColor = _selectedBackgroundColor;
    metrics->_separatorColor = _separatorColor;
    metrics->_sectionSeparatorColor = _sectionSeparatorColor;
    metrics->_sectionSeparatorInsets = _sectionSeparatorInsets;
    metrics->_hasPlaceholder = _hasPlaceholder;
    metrics->_showsSectionSeparatorWhenLastSection = _showsSectionSeparatorWhenLastSection;
	metrics->_supplementaryViews = [_supplementaryViews mutableCopy];
    metrics->_flags = _flags;
    return metrics;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    _flags.backgroundColor = YES;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
    _flags.selectedBackgroundColor = YES;
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    _flags.separatorColor = YES;
}

- (void)setSectionSeparatorColor:(UIColor *)sectionSeparatorColor
{
    _sectionSeparatorColor = sectionSeparatorColor;
    _flags.sectionSeparatorColor = YES;
}

- (void)setShowsSectionSeparatorWhenLastSection:(BOOL)showsSectionSeparatorWhenLastSection
{
    _showsSectionSeparatorWhenLastSection = showsSectionSeparatorWhenLastSection;
    _flags.showsSectionSeparatorWhenLastSection = YES;
}

- (void)setSupplementaryViews:(NSArray *)supplementaryViews {
	_supplementaryViews = [NSMutableArray arrayWithArray:supplementaryViews];
}

- (BSHLayoutSupplementaryMetrics *)newHeader
{
	return [self newSupplementaryMetricsOfKind:UICollectionElementKindSectionHeader];
}

- (BSHLayoutSupplementaryMetrics *)newFooter
{
	return [self newSupplementaryMetricsOfKind:UICollectionElementKindSectionFooter];
}

- (BSHLayoutSupplementaryMetrics *)newSupplementaryMetricsOfKind:(NSString *)kind
{
	BSHLayoutSupplementaryMetrics *metrics = [[BSHLayoutSupplementaryMetrics alloc] initWithSupplementaryViewKind:kind];
	if (!_supplementaryViews) {
		_supplementaryViews = [NSMutableArray arrayWithObject:metrics];
	} else {
		[_supplementaryViews addObject:metrics];
	}
	return metrics;
}

- (void)applyValuesFromMetrics:(BSHLayoutSectionMetrics *)metrics
{
    if (!metrics)
        return;

    if (!UIEdgeInsetsEqualToEdgeInsets(metrics.padding, UIEdgeInsetsZero))
        self.padding = metrics.padding;

    if (!UIEdgeInsetsEqualToEdgeInsets(metrics.separatorInsets, UIEdgeInsetsZero))
        self.separatorInsets = metrics.separatorInsets;

    if (!UIEdgeInsetsEqualToEdgeInsets(metrics.sectionSeparatorInsets, UIEdgeInsetsZero))
        self.sectionSeparatorInsets = metrics.sectionSeparatorInsets;

    if (metrics.rowHeight)
        self.rowHeight = metrics.rowHeight;

    if (metrics->_flags.backgroundColor)
        self.backgroundColor = metrics.backgroundColor;

    if (metrics->_flags.selectedBackgroundColor)
        self.selectedBackgroundColor = metrics.selectedBackgroundColor;

    if (metrics->_flags.sectionSeparatorColor)
        self.sectionSeparatorColor = metrics.sectionSeparatorColor;

    if (metrics->_flags.separatorColor)
        self.separatorColor = metrics.separatorColor;

    if (metrics->_flags.showsSectionSeparatorWhenLastSection)
        self.showsSectionSeparatorWhenLastSection = metrics.showsSectionSeparatorWhenLastSection;

    if (metrics.hasPlaceholder)
        self.hasPlaceholder = YES;

	if (metrics.supplementaryViews) {
		self.supplementaryViews = [[NSArray arrayWithArray:self.supplementaryViews] arrayByAddingObjectsFromArray:metrics.supplementaryViews];
	}
}

@end
