var
  upperBand                      : float;
  lowerBand                      : float;
  distanciaBandas                : float;
  precoEntrada,stopGain,stopLoss : float;
  candleEntrada                  : integer;
  qtdContratos                   : integer;
  entradasHoje                   : integer;
  ultimoDia                      : integer;

begin
  qtdContratos := 1;

  if Date <> ultimoDia then
  begin
    entradasHoje := 0;
    ultimoDia := Date;
  end; // fim do if Date <> ultimoDia

  if Time < 1650 then
  begin
    upperBand := BollingerBands(2.0,20,0)|0|;
    lowerBand := BollingerBands(2.0,20,0)|1|;
    distanciaBandas := upperBand - lowerBand;

    if (candleEntrada > 0) and ( not HasPosition) and (CurrentBar - candleEntrada >= 2) then
      begin
        CancelPendingOrders();
        candleEntrada := 0;
      end; // fim do if candleEntrada > 0

    if (distanciaBandas <= 250) then
      begin
        if ( not HasPosition) and (entradasHoje < 2) then
          begin
            if (Close[1] > upperBand[1]) then
              begin
                precoEntrada := High[1] + 5;
                BuyLimit(precoEntrada,qtdContratos);
                candleEntrada := CurrentBar;
                entradasHoje := entradasHoje + 1;
              end // fim do if Close > upperBand
            else if (Close[1] < lowerBand[1]) then
              begin
                precoEntrada := Low[1] - 5;
                SellShortLimit(precoEntrada,qtdContratos);
                candleEntrada := CurrentBar;
                entradasHoje := entradasHoje + 1;
              end; // fim do if Close < lowerBand
          end // fim do if not HasPosition and entradasHoje < 2
          else if HasPosition then
            begin
              if IsBought then
                begin
                  stopGain := BuyPrice + 150;
                  stopLoss := BuyPrice - 150;
                  SellToCoverLimit(stopGain,qtdContratos);
                  SellToCoverStop(stopLoss,qtdContratos);
                end // fim do if IsBought
              else if IsSold then
                begin
                  stopGain := SellPrice - 150;
                  stopLoss := SellPrice + 150;
                  BuyToCoverLimit(stopGain,qtdContratos);
                  BuyToCoverStop(stopLoss,qtdContratos);
                end; // fim do if IsSold
            end; // fim do if HasPosition
        end; // fim do if distanciaBandas <= 250
  end // fim do if Time < 1650
  else
  begin
    CancelPendingOrders();
  end; // fim do else Time < 1650
end;