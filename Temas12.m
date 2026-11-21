classdef Temas12 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        RadioresultadodEditField        matlab.ui.control.EditField
        RadioresultadodEditFieldLabel   matlab.ui.control.Label
        PmpotenciamedidaEditField       matlab.ui.control.EditField
        PmpotenciamedidaEditFieldLabel  matlab.ui.control.Label
        PnpotenciaderuidoEditField      matlab.ui.control.EditField
        PnpotenciaderuidoEditFieldLabel matlab.ui.control.Label
        PupotenciadeumbralEditField     matlab.ui.control.EditField
        PupotenciadeumbralEditFieldLabel matlab.ui.control.Label
        CerrarButton                    matlab.ui.control.Button
        GuardarButton                   matlab.ui.control.Button
        BorrarButton                    matlab.ui.control.Button
        Potencia_rebudaButton           matlab.ui.control.Button
        Lp_perduesButton                matlab.ui.control.Button
        CalcularButton                  matlab.ui.control.Button
        ModulacinDropDown               matlab.ui.control.DropDown
        ModulacinDropDownLabel          matlab.ui.control.Label
        ZonaDropDown                    matlab.ui.control.DropDown
        ZonaDropDownLabel               matlab.ui.control.Label
        CiudadDropDown                  matlab.ui.control.DropDown
        CiudadDropDownLabel             matlab.ui.control.Label
        RbEditField                     matlab.ui.control.NumericEditField
        RbEditFieldLabel                matlab.ui.control.Label
        PbTasadeerrorEditField          matlab.ui.control.NumericEditField
        PbTasadeerrorEditFieldLabel     matlab.ui.control.Label
        SigmaDesviacinEditField         matlab.ui.control.NumericEditField
        SigmaDesviacinEditFieldLabel    matlab.ui.control.Label
        BWAnchodebandaEditField         matlab.ui.control.NumericEditField
        BWAnchodebandaEditFieldLabel    matlab.ui.control.Label
        GFactorderuidoEditField         matlab.ui.control.NumericEditField
        GFactorderuidoEditFieldLabel    matlab.ui.control.Label
        GrGananciadereceptorEditField   matlab.ui.control.NumericEditField
        GrGananciadereceptorEditFieldLabel matlab.ui.control.Label
        GtGananciadeantenaEditField     matlab.ui.control.NumericEditField
        GtGananciadeantenaEditFieldLabel matlab.ui.control.Label
        PtpotenciatransmitidaEditField  matlab.ui.control.NumericEditField
        PtpotenciatransmitidaEditFieldLabel matlab.ui.control.Label
        HmalturadelmvilEditField        matlab.ui.control.NumericEditField
        HmalturadelmvilEditFieldLabel   matlab.ui.control.Label
        HbalturadebaseEditField         matlab.ui.control.NumericEditField
        HbalturadebaseEditFieldLabel    matlab.ui.control.Label
        FrecfrecuenciaEditField         matlab.ui.control.NumericEditField
        FrecfrecuenciaEditFieldLabel    matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalcularButton
        function CalcularButtonPushed(app, event)
            f = app.FrecfrecuenciaEditField.Value;
            hb = app.HbalturadebaseEditField.Value;
            hm = app.HmalturadelmvilEditField.Value;
            Pt_dBm = app.PtpotenciatransmitidaEditField.Value;
            Gt = app.GtGananciadeantenaEditField.Value;
            Gr = app.GrGananciadereceptorEditField.Value;
            F_dB = app.GFactorderuidoEditField.Value;
            BW = app.BWAnchodebandaEditField.Value;
            sigma = app.SigmaDesviacinEditField.Value;
            Pb = app.PbTasadeerrorEditField.Value;
            Rb = app.RbEditField.Value;

            if any([f, hb, hm, Pt_dBm, BW, sigma, Pb, Rb] <= 0)
                uialert(app.UIFigure, 'Todos los campos deben ser mayores que cero.', 'Error');
                return;
            end

            k = 1.38e-23; To = 290;
            Pn_dBm = 10*log10(k * To * (10^(F_dB/10)) * BW) + 30;
            gamma_o = 1 / (2 * Pb);
            gamma_o_dB = 10 * log10(gamma_o);
            Pu_dBm = Pn_dBm + gamma_o_dB;
            Pm_dBm = Pu_dBm + 0.9 * sqrt(2) * sigma;
            Lp_max = Pt_dBm + Gt + Gr - Pm_dBm;

            ciudad = app.CiudadDropDown.Value;
            if strcmp(ciudad, 'Ciudad grande')
                if f < 200
                    a_hm = 8.29*(log10(1.54*hm))^2 - 1.1;
                else
                    a_hm = 3.2*(log10(11.75*hm))^2 - 4.97;
                end
            else
                a_hm = (1.1*log10(f) - 0.7)*hm - (1.56*log10(f) - 0.8);
            end
            A = 69.55 + 26.16*log10(f) - 13.82*log10(hb) - a_hm;
            B = 44.9 - 6.55*log10(hb);
            d_km = 10^((Lp_max - A) / B);

            app.PupotenciadeumbralEditField.Value = sprintf('%.2f dBm', Pu_dBm);
            app.PnpotenciaderuidoEditField.Value = sprintf('%.2f dBm', Pn_dBm);
            app.PmpotenciamedidaEditField.Value = sprintf('%.2f dBm', Pm_dBm);
            app.RadioresultadodEditField.Value = sprintf('%.2f km', d_km);

            d_vec = linspace(0.1, 20, 100);
            Lp_vec = A + B*log10(d_vec);
            plot(app.UIAxes, d_vec, Lp_vec, 'b-', 'LineWidth', 2);
            title(app.UIAxes, 'Pérdidas vs Distancia');
            xlabel(app.UIAxes, 'Distancia (km)');
            ylabel(app.UIAxes, 'Pérdidas (dB)');
            grid(app.UIAxes, 'on');
        end

        % Button pushed function: Lp_perduesButton
        function Lp_perduesButtonPushed(app, event)
            f = app.FrecfrecuenciaEditField.Value;
            hb = app.HbalturadebaseEditField.Value;
            hm = app.HmalturadelmvilEditField.Value;
            ciudad = app.CiudadDropDown.Value;
            if strcmp(ciudad, 'Ciudad grande')
                if f < 200
                    a_hm = 8.29*(log10(1.54*hm))^2 - 1.1;
                else
                    a_hm = 3.2*(log10(11.75*hm))^2 - 4.97;
                end
            else
                a_hm = (1.1*log10(f) - 0.7)*hm - (1.56*log10(f) - 0.8);
            end
            A = 69.55 + 26.16*log10(f) - 13.82*log10(hb) - a_hm;
            B = 44.9 - 6.55*log10(hb);
            Lp_1km = A + B*log10(1);
            uialert(app.UIFigure, sprintf('Pérdidas a 1 km: %.2f dB', Lp_1km), 'Resultado');
        end

        % Button pushed function: Potencia_rebudaButton
        function Potencia_rebudaButtonPushed(app, event)
            Pt = app.PtpotenciatransmitidaEditField.Value;
            Gt = app.GtGananciadeantenaEditField.Value;
            Gr = app.GrGananciadereceptorEditField.Value;
            f = app.FrecfrecuenciaEditField.Value;
            hb = app.HbalturadebaseEditField.Value;
            hm = app.HmalturadelmvilEditField.Value;
            ciudad = app.CiudadDropDown.Value;
            if strcmp(ciudad, 'Ciudad grande')
                if f < 200
                    a_hm = 8.29*(log10(1.54*hm))^2 - 1.1;
                else
                    a_hm = 3.2*(log10(11.75*hm))^2 - 4.97;
                end
            else
                a_hm = (1.1*log10(f) - 0.7)*hm - (1.56*log10(f) - 0.8);
            end
            A = 69.55 + 26.16*log10(f) - 13.82*log10(hb) - a_hm;
            B = 44.9 - 6.55*log10(hb);
            Lp_1km = A + B*log10(1);
            Pr = Pt + Gt + Gr - Lp_1km;
            uialert(app.UIFigure, sprintf('Potencia recibida a 1 km: %.2f dBm', Pr), 'Resultado');
        end

        % Button pushed function: BorrarButton
        function BorrarButtonPushed(app, event)
            app.FrecfrecuenciaEditField.Value = 0;
            app.HbalturadebaseEditField.Value = 0;
            app.HmalturadelmvilEditField.Value = 0;
            app.PtpotenciatransmitidaEditField.Value = 0;
            app.GtGananciadeantenaEditField.Value = 0;
            app.GrGananciadereceptorEditField.Value = 0;
            app.GFactorderuidoEditField.Value = 0;
            app.BWAnchodebandaEditField.Value = 0;
            app.SigmaDesviacinEditField.Value = 0;
            app.PbTasadeerrorEditField.Value = 0;
            app.RbEditField.Value = 0;
            app.PupotenciadeumbralEditField.Value = '';
            app.PnpotenciaderuidoEditField.Value = '';
            app.PmpotenciamedidaEditField.Value = '';
            app.RadioresultadodEditField.Value = '';
            cla(app.UIAxes);
        end

        % Button pushed function: GuardarButton
        function GuardarButtonPushed(app, event)
            [file, path] = uiputfile({'*.png'; '*.jpg'}, 'Guardar gráfica');
            if file ~= 0
                exportgraphics(app.UIAxes, fullfile(path, file));
                uialert(app.UIFigure, 'Gráfica guardada correctamente.', 'Éxito');
            end
        end

        % Button pushed function: CerrarButton
        function CerrarButtonPushed(app, event)
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 850 650];
            app.UIFigure.Name = 'Simulador - Temas 1 y 2';

            % ==========================================
            % COLUMNA 1: ENTRADAS (Izquierda)
            % ==========================================
            y_pos = 590; dy = 38;

            app.FrecfrecuenciaEditFieldLabel = uilabel(app.UIFigure);
            app.FrecfrecuenciaEditFieldLabel.HorizontalAlignment = 'right';
            app.FrecfrecuenciaEditFieldLabel.Position = [30 y_pos 100 22];
            app.FrecfrecuenciaEditFieldLabel.Text = 'Frec (MHz)';
            app.FrecfrecuenciaEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrecfrecuenciaEditField.Position = [140 y_pos 100 22];

            app.HbalturadebaseEditFieldLabel = uilabel(app.UIFigure);
            app.HbalturadebaseEditFieldLabel.HorizontalAlignment = 'right';
            app.HbalturadebaseEditFieldLabel.Position = [30 y_pos-dy 100 22];
            app.HbalturadebaseEditFieldLabel.Text = 'Hb (m)';
            app.HbalturadebaseEditField = uieditfield(app.UIFigure, 'numeric');
            app.HbalturadebaseEditField.Position = [140 y_pos-dy 100 22];

            app.HmalturadelmvilEditFieldLabel = uilabel(app.UIFigure);
            app.HmalturadelmvilEditFieldLabel.HorizontalAlignment = 'right';
            app.HmalturadelmvilEditFieldLabel.Position = [30 y_pos-2*dy 100 22];
            app.HmalturadelmvilEditFieldLabel.Text = 'Hm (m)';
            app.HmalturadelmvilEditField = uieditfield(app.UIFigure, 'numeric');
            app.HmalturadelmvilEditField.Position = [140 y_pos-2*dy 100 22];

            app.PtpotenciatransmitidaEditFieldLabel = uilabel(app.UIFigure);
            app.PtpotenciatransmitidaEditFieldLabel.HorizontalAlignment = 'right';
            app.PtpotenciatransmitidaEditFieldLabel.Position = [30 y_pos-3*dy 100 22];
            app.PtpotenciatransmitidaEditFieldLabel.Text = 'Pt (dBm)';
            app.PtpotenciatransmitidaEditField = uieditfield(app.UIFigure, 'numeric');
            app.PtpotenciatransmitidaEditField.Position = [140 y_pos-3*dy 100 22];

            app.GtGananciadeantenaEditFieldLabel = uilabel(app.UIFigure);
            app.GtGananciadeantenaEditFieldLabel.HorizontalAlignment = 'right';
            app.GtGananciadeantenaEditFieldLabel.Position = [30 y_pos-4*dy 100 22];
            app.GtGananciadeantenaEditFieldLabel.Text = 'Gt (dB)';
            app.GtGananciadeantenaEditField = uieditfield(app.UIFigure, 'numeric');
            app.GtGananciadeantenaEditField.Position = [140 y_pos-4*dy 100 22];

            app.GrGananciadereceptorEditFieldLabel = uilabel(app.UIFigure);
            app.GrGananciadereceptorEditFieldLabel.HorizontalAlignment = 'right';
            app.GrGananciadereceptorEditFieldLabel.Position = [30 y_pos-5*dy 100 22];
            app.GrGananciadereceptorEditFieldLabel.Text = 'Gr (dB)';
            app.GrGananciadereceptorEditField = uieditfield(app.UIFigure, 'numeric');
            app.GrGananciadereceptorEditField.Position = [140 y_pos-5*dy 100 22];

            app.GFactorderuidoEditFieldLabel = uilabel(app.UIFigure);
            app.GFactorderuidoEditFieldLabel.HorizontalAlignment = 'right';
            app.GFactorderuidoEditFieldLabel.Position = [30 y_pos-6*dy 100 22];
            app.GFactorderuidoEditFieldLabel.Text = 'G (dB)';
            app.GFactorderuidoEditField = uieditfield(app.UIFigure, 'numeric');
            app.GFactorderuidoEditField.Position = [140 y_pos-6*dy 100 22];

            app.BWAnchodebandaEditFieldLabel = uilabel(app.UIFigure);
            app.BWAnchodebandaEditFieldLabel.HorizontalAlignment = 'right';
            app.BWAnchodebandaEditFieldLabel.Position = [30 y_pos-7*dy 100 22];
            app.BWAnchodebandaEditFieldLabel.Text = 'BW (Hz)';
            app.BWAnchodebandaEditField = uieditfield(app.UIFigure, 'numeric');
            app.BWAnchodebandaEditField.Position = [140 y_pos-7*dy 100 22];

            app.SigmaDesviacinEditFieldLabel = uilabel(app.UIFigure);
            app.SigmaDesviacinEditFieldLabel.HorizontalAlignment = 'right';
            app.SigmaDesviacinEditFieldLabel.Position = [30 y_pos-8*dy 100 22];
            app.SigmaDesviacinEditFieldLabel.Text = 'Sigma (dB)';
            app.SigmaDesviacinEditField = uieditfield(app.UIFigure, 'numeric');
            app.SigmaDesviacinEditField.Position = [140 y_pos-8*dy 100 22];

            app.PbTasadeerrorEditFieldLabel = uilabel(app.UIFigure);
            app.PbTasadeerrorEditFieldLabel.HorizontalAlignment = 'right';
            app.PbTasadeerrorEditFieldLabel.Position = [30 y_pos-9*dy 100 22];
            app.PbTasadeerrorEditFieldLabel.Text = 'Pb';
            app.PbTasadeerrorEditField = uieditfield(app.UIFigure, 'numeric');
            app.PbTasadeerrorEditField.Position = [140 y_pos-9*dy 100 22];

            app.RbEditFieldLabel = uilabel(app.UIFigure);
            app.RbEditFieldLabel.HorizontalAlignment = 'right';
            app.RbEditFieldLabel.Position = [30 y_pos-10*dy 100 22];
            app.RbEditFieldLabel.Text = 'Rb (bps)';
            app.RbEditField = uieditfield(app.UIFigure, 'numeric');
            app.RbEditField.Position = [140 y_pos-10*dy 100 22];

            % ==========================================
            % COLUMNA 2: RESULTADOS Y CONFIGURACIÓN (Centro)
            % ==========================================
            app.PupotenciadeumbralEditFieldLabel = uilabel(app.UIFigure);
            app.PupotenciadeumbralEditFieldLabel.HorizontalAlignment = 'right';
            app.PupotenciadeumbralEditFieldLabel.Position = [290 y_pos 100 22];
            app.PupotenciadeumbralEditFieldLabel.Text = 'Pu (umbral)';
            app.PupotenciadeumbralEditField = uieditfield(app.UIFigure, 'text');
            app.PupotenciadeumbralEditField.Position = [400 y_pos 100 22];
            app.PupotenciadeumbralEditField.Editable = 'off';

            app.PnpotenciaderuidoEditFieldLabel = uilabel(app.UIFigure);
            app.PnpotenciaderuidoEditFieldLabel.HorizontalAlignment = 'right';
            app.PnpotenciaderuidoEditFieldLabel.Position = [290 y_pos-dy 100 22];
            app.PnpotenciaderuidoEditFieldLabel.Text = 'Pn (ruido)';
            app.PnpotenciaderuidoEditField = uieditfield(app.UIFigure, 'text');
            app.PnpotenciaderuidoEditField.Position = [400 y_pos-dy 100 22];
            app.PnpotenciaderuidoEditField.Editable = 'off';

            app.PmpotenciamedidaEditFieldLabel = uilabel(app.UIFigure);
            app.PmpotenciamedidaEditFieldLabel.HorizontalAlignment = 'right';
            app.PmpotenciamedidaEditFieldLabel.Position = [290 y_pos-2*dy 100 22];
            app.PmpotenciamedidaEditFieldLabel.Text = 'Pm (medida)';
            app.PmpotenciamedidaEditField = uieditfield(app.UIFigure, 'text');
            app.PmpotenciamedidaEditField.Position = [400 y_pos-2*dy 100 22];
            app.PmpotenciamedidaEditField.Editable = 'off';

            app.RadioresultadodEditFieldLabel = uilabel(app.UIFigure);
            app.RadioresultadodEditFieldLabel.HorizontalAlignment = 'right';
            app.RadioresultadodEditFieldLabel.Position = [290 y_pos-3*dy 100 22];
            app.RadioresultadodEditFieldLabel.Text = 'Radio (d)';
            app.RadioresultadodEditField = uieditfield(app.UIFigure, 'text');
            app.RadioresultadodEditField.Position = [400 y_pos-3*dy 100 22];
            app.RadioresultadodEditField.Editable = 'off';

            app.CiudadDropDownLabel = uilabel(app.UIFigure);
            app.CiudadDropDownLabel.HorizontalAlignment = 'right';
            app.CiudadDropDownLabel.Position = [290 y_pos-4.5*dy 100 22];
            app.CiudadDropDownLabel.Text = 'Ciudad';
            app.CiudadDropDown = uidropdown(app.UIFigure);
            app.CiudadDropDown.Position = [400 y_pos-4.5*dy 120 22];
            app.CiudadDropDown.Items = {'Ciudad grande', 'Ciudad pequeña/mediana'};
            app.CiudadDropDown.Value = 'Ciudad grande';

            app.ZonaDropDownLabel = uilabel(app.UIFigure);
            app.ZonaDropDownLabel.HorizontalAlignment = 'right';
            app.ZonaDropDownLabel.Position = [290 y_pos-5.5*dy 100 22];
            app.ZonaDropDownLabel.Text = 'Zona';
            app.ZonaDropDown = uidropdown(app.UIFigure);
            app.ZonaDropDown.Position = [400 y_pos-5.5*dy 120 22];
            app.ZonaDropDown.Items = {'Urbana', 'Suburbana', 'Rural'};
            app.ZonaDropDown.Value = 'Urbana';

            app.ModulacinDropDownLabel = uilabel(app.UIFigure);
            app.ModulacinDropDownLabel.HorizontalAlignment = 'right';
            app.ModulacinDropDownLabel.Position = [290 y_pos-6.5*dy 100 22];
            app.ModulacinDropDownLabel.Text = 'Modulación';
            app.ModulacinDropDown = uidropdown(app.UIFigure);
            app.ModulacinDropDown.Position = [400 y_pos-6.5*dy 120 22];
            app.ModulacinDropDown.Items = {'QPSK', 'MSK', 'GMSK', '8-PSK'};
            app.ModulacinDropDown.Value = 'QPSK';

            % ==========================================
            % COLUMNA 3: ACCIONES (Derecha)
            % ==========================================
            btn_x = 570; btn_w = 150;
            
            app.CalcularButton = uibutton(app.UIFigure, 'push');
            app.CalcularButton.ButtonPushedFcn = createCallbackFcn(app, @CalcularButtonPushed, true);
            app.CalcularButton.Position = [btn_x y_pos btn_w 30];
            app.CalcularButton.Text = 'Calcular';

            app.Lp_perduesButton = uibutton(app.UIFigure, 'push');
            app.Lp_perduesButton.ButtonPushedFcn = createCallbackFcn(app, @Lp_perduesButtonPushed, true);
            app.Lp_perduesButton.Position = [btn_x y_pos-dy btn_w 30];
            app.Lp_perduesButton.Text = 'Lp (pérdidas)';

            app.Potencia_rebudaButton = uibutton(app.UIFigure, 'push');
            app.Potencia_rebudaButton.ButtonPushedFcn = createCallbackFcn(app, @Potencia_rebudaButtonPushed, true);
            app.Potencia_rebudaButton.Position = [btn_x y_pos-2*dy btn_w 30];
            app.Potencia_rebudaButton.Text = 'Potencia recibida';

            app.BorrarButton = uibutton(app.UIFigure, 'push');
            app.BorrarButton.ButtonPushedFcn = createCallbackFcn(app, @BorrarButtonPushed, true);
            app.BorrarButton.Position = [btn_x y_pos-3*dy btn_w 30];
            app.BorrarButton.Text = 'Borrar';

            app.GuardarButton = uibutton(app.UIFigure, 'push');
            app.GuardarButton.ButtonPushedFcn = createCallbackFcn(app, @GuardarButtonPushed, true);
            app.GuardarButton.Position = [btn_x y_pos-4*dy btn_w 30];
            app.GuardarButton.Text = 'Guardar';

            app.CerrarButton = uibutton(app.UIFigure, 'push');
            app.CerrarButton.ButtonPushedFcn = createCallbackFcn(app, @CerrarButtonPushed, true);
            app.CerrarButton.Position = [btn_x y_pos-5*dy btn_w 30];
            app.CerrarButton.Text = 'Cerrar';

            % ==========================================
            % GRÁFICA (Abarca el tercio inferior completo)
            % ==========================================
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Pérdidas vs Distancia')
            xlabel(app.UIAxes, 'Distancia (km)')
            ylabel(app.UIAxes, 'Pérdidas (dB)')
            % Posición: X=30, Y=30, Ancho=800, Alto=200
            % Esto ocupa todo el ancho inferior, sin tapar nada
            app.UIAxes.Position = [30 30 800 200]; 
            app.UIAxes.Toolbar.Visible = 'off'; 
            grid(app.UIAxes, 'on');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = Temas12
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end
        function delete(app)
            delete(app.UIFigure)
        end
    end
end