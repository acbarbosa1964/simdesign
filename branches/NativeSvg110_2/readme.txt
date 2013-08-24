Pyro Readme
===========
Author: Nils Haeck
Date: 20may2011

Classes
=======

TPersistent
  TpgElement                                           pgElement.pas
    TpgRefElement                                      pgElement.pas
    TpgStyleable                                       pgElement.pas
      TpgStyle                                         pgElement.pas

        TpgSizeable                                    pgSizeable.pas
          TpgPaintable                                 pgPaintable.pas
            TpgGraphic                                 pgGraphic.pas
              TpgGroup                                 pgGraphic.pas
                TpgPaintServer                         pgPaintServer.pas
                TpgBaseViewPort                        pgViewPort.pas
                  TpgViewPort                          pgViewPort.pas
            
            
TPersistent            
  TpgProp                                              pgElement.pas
    TpgStoredProp                                      pgElement.pas
      TpgBoolProp                                      pgElement.pas
      TpgIntProp                                       pgElement.pas

        TpgUsageUnitsProp                              pgPaintServer.pas
        TpgEditorOptionsProp                           pgGraphic.pas
        TpgPreserveAspectProp                          pgViewPort.pas
        TpgMeetOrSliceProp                             pgViewPort.pas

      TpgFloatProp                                     pgElement.pas

        TpgLengthProp                                  pgSizeable.pas
          TpgHLengthProp                               pgSizeable.pas
          TpgVLengthProp                               pgSizeable.pas

      TpgStringProp                                    pgElement.pas
      TpgBinaryProp                                    pgElement.pas
      TpgRefProp                                       pgElement.pas
        TpgCountedRefProp                              pgElement.pas
        TpgStyleProp                                   pgElement.pas

      TpgFloatListProp                                 pgSizeable.pas
      TpgLengthListProp                                pgSizeable.pas
        TpgHLengthListProp                             pgSizeable.pas
        TpgVLengthListProp                             pgSizeable.pas
      TpgTransformProp                                 pgGraphic.pas
      TpgViewBoxProp                                   pgViewPort.pas
      
TDebugComponent                                        sdDebug.pas
  TpgContainer                                         pgElement.pas
    TpgStoredContainer                                 pgElement.pas
  
TPersistent
  TpgPropInfo                                          pgElement.pas
  
TPersistent
  TpgElementInfo                                       pgElement.pas

TPersistent
  TpgStorage                                           pgElement.pas


Pyro Document-Object-Model design strategy
==========================================

The two main objects are TpgProp and TpgElement. TpgElement instances can have TpgProp properties
in a local list but can also have properties by various other ways. They are found with method
PropById, and then thru TpgElement.CheckPropLocations:

Local property list:
TpgElement.FLocalProps (protected)

Reference properties:
TpgElement.CheckReferenceProps

Properties of the parent that can be inherited:
FParent.CheckPropLocations

Finally, default properties:
FOwner.FDefaultElement.FLocalProps.ById



