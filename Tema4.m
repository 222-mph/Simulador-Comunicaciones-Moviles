classdef Tema4 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        AreaCoberturaEditField          matlab.ui.control.EditField
        AreaCoberturaEditFieldLabel     matlab.ui.control.Label
        RadioREditField                 matlab.ui.control.EditField
        RadioREditFieldLabel            matlab.ui.control.Label
        NumRecursosEditField            matlab.ui.control.EditField
        NumRecursosEditFieldLabel       matlab.ui.control.Label
        PdropEditField                  matlab.ui.control.EditField
        PdropEditFieldLabel             matlab.ui.control.Label
        PhEditField                     matlab.ui.control.EditField
        PhEditFieldLabel                matlab.ui.control.Label
        TraficoTotalEditField           matlab.ui.control.EditField
        TraficoTotalEditFieldLabel      matlab.ui.control.Label
        PbEditField                     matlab.ui.control.EditField
        PbEditFieldLabel                matlab.ui.control.Label
        CerrarButton                    matlab.ui.control.Button
        CalcularButton                  matlab.ui.control.Button
        AntenasDropDown                 matlab.ui.control.DropDown
        AntenasDropDownLabel            matlab.ui.control.Label
        DensidadEditField               matlab.ui.control.NumericEditField
        DensidadEditFieldLabel          matlab.ui.control.Label
        PdropDisenoEditField            matlab.ui.control.NumericEditField
        PdropDisenoEditFieldLabel       matlab.ui.control.Label
        PBDisenoEditField               matlab.ui.control.NumericEditField
        PBDisenoEditFieldLabel          matlab.ui.control.Label
        CIRdBEditField                  matlab.ui.control.NumericEditField
        CIRdBEditFieldLabel             matlab.ui.control.Label
        RadiocanalesEditField           matlab.ui.control.NumericEditField
        RadiocanalesEditFieldLabel      matlab.ui.control.Label
        TsEditField                     matlab.ui.control.NumericEditField
        TsEditFieldLabel                matlab.ui.control.Label
        QuEditField                     matlab.ui.control.NumericEditField
        QuEditFieldLabel                matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalcularButton
        function CalcularButtonPushed(app, event)
            % 1. Leer datos de entrada
            Qu = app.QuEditField.Value;              % Llamadas/hora por usuario
            Ts = app.TsEditField.Value;              % Duración media (s)
            radiocanales_total = app.RadiocanalesEditField.Value; % Total en el sistema
            CIR_dB = app.CIRdBEditField.Value;       % CIR requerida
            PB_diseno = app.PBDisenoEditField.Value; % Probabilidad de bloqueo
            Pdrop_diseno = app.PdropDisenoEditField.Value; % Prob. de caída
            densidad = app.DensidadEditField.Value;  % usuarios/km^2
            antena = app.AntenasDropDown.Value;      % 'Omnidireccional', '120°', '60°'
            
            % Validar datos
            if any([Qu, Ts, radiocanales_total, CIR_dB, PB_diseno, Pdrop_diseno, densidad] <= 0)
                uialert(app.UIFigure, 'Todos los campos deben ser mayores que cero.', 'Error');
                return;
            end

            % 2. Factor de reuso K (Fórmula 3.8 / 3.10 con alpha=4 para tierra plana)
            CIR_lin = 10^(CIR_dB/10);
            if strcmp(antena, 'Omnidireccional')
                n = 6;
            elseif strcmp(antena, '120°')
                n = 2;
            else
                n = 1;
            end
            
            alpha = 4; % Para GSM en tierra plana
            K_calc = (1/3) * (1 + (n * CIR_lin)^(2/alpha));
            
            % Ajustar K al siguiente entero válido
            K_validos = [1, 3, 4, 7, 9, 12, 13, 16, 19, 21, 25, 27, 28, 31, 36, 37, 39, 43, 48, 49];
            K_final = K_validos(find(K_validos >= K_calc, 1));
            if isempty(K_final)
                K_final = K_validos(end);
            end

            % 3. Canales por celda (Radiocanales / K)
            canales_celda = floor(radiocanales_total / K_final);
            if strcmp(antena, 'Omnidireccional')
                sectores = 1;
            elseif strcmp(antena, '120°')
                sectores = 3;
            else
                sectores = 6;
            end
            canales_sector = floor(canales_celda / sectores);

            % 4. Número de recursos (TS) por celda
            % En GSM, cada radiocanal tiene 8 TS. 
            % Para el cálculo de tráfico, se reserva 1 TS por celda para señalización.
            recursos = (canales_celda * 8) - 1; 
            
            % Para el tráfico, usamos los TS de tráfico (recursos - 1 de señalización)
            TS_trafico = recursos - 1; 

            % 5. Tráfico por usuario (Erlang)
            A_usuario = (Qu * Ts) / 3600; 

            % 6. Tráfico total por celda (usando Erlang-B con los TS de tráfico)
            A_celda = 0;
            paso = 0.001;
            while erlang_b(A_celda, TS_trafico) <= PB_diseno
                A_celda = A_celda + paso;
                if A_celda > 1000, break; end
            end
            A_celda = A_celda - paso;

            % 7. Cálculo de Ph (Probabilidad de handover)
            % Dato del ejercicio
            Ph = 0.131; 
            
            % 8. Cálculo de Pdrop (Probabilidad de caída)
            Pbh = PB_diseno;
            Pdrop = (Ph * Pbh) / (1 - Pbh * (1 - Ph));

            % 9. Cálculo del área de cobertura
            lambda_a_km2 = (densidad * Qu) / 3600; % llamadas/s/km^2
            lambda_h_km2 = lambda_a_km2 * (Ph / (1 - Ph)); 
            A_km2 = (lambda_a_km2 + lambda_h_km2) * Ts * (1 - Ph);
            
            if A_km2 > 0
                Area = A_celda / A_km2;
            else
                Area = 0;
            end
            R = sqrt(Area / pi);

            % 10. Mostrar resultados
            app.TraficoTotalEditField.Value = sprintf('%.2f Erl', A_celda);
            app.PbEditField.Value = sprintf('%.4f', PB_diseno);
            app.PhEditField.Value = sprintf('%.3f', Ph);
            app.PdropEditField.Value = sprintf('%.3f %%', Pdrop * 100); 
            app.NumRecursosEditField.Value = sprintf('%d TS', recursos);
            app.RadioREditField.Value = sprintf('%.2f km', R);
            app.AreaCoberturaEditField.Value = sprintf('%.2f km²', Area);
            
            % 11. Graficar Erlang-B vs Canales
            canales_vec = 1:max(20, TS_trafico+5);
            Pb_vec = zeros(size(canales_vec));
            for i = 1:length(canales_vec)
                Pb_vec(i) = erlang_b(A_celda, canales_vec(i));
            end
            plot(app.UIAxes, canales_vec, Pb_vec, 'b-o', 'LineWidth', 1.5);
            hold(app.UIAxes, 'on');
            plot(app.UIAxes, TS_trafico, PB_diseno, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
            hold(app.UIAxes, 'off');
            title(app.UIAxes, 'Probabilidad de bloqueo (Erlang-B)');
            xlabel(app.UIAxes, 'Número de canales (TS)');
            ylabel(app.UIAxes, 'Probabilidad de bloqueo');
            grid(app.UIAxes, 'on');
            legend(app.UIAxes, 'Curva Erlang-B', 'Punto de diseño', 'Location', 'northeast');
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
            app.UIFigure.Name = 'Simulador - Tema 4 (GSM y Tráfico)';

            % ==========================================
            % COLUMNA 1: ENTRADAS (Izquierda)
            % ==========================================
            y_pos = 590; dy = 38;

            app.QuEditFieldLabel = uilabel(app.UIFigure);
            app.QuEditFieldLabel.HorizontalAlignment = 'right';
            app.QuEditFieldLabel.Position = [30 y_pos 100 22];
            app.QuEditFieldLabel.Text = 'Qu (llam/h)';
            app.QuEditField = uieditfield(app.UIFigure, 'numeric');
            app.QuEditField.Position = [140 y_pos 100 22];

            app.TsEditFieldLabel = uilabel(app.UIFigure);
            app.TsEditFieldLabel.HorizontalAlignment = 'right';
            app.TsEditFieldLabel.Position = [30 y_pos-dy 100 22];
            app.TsEditFieldLabel.Text = 'Ts (s)';
            app.TsEditField = uieditfield(app.UIFigure, 'numeric');
            app.TsEditField.Position = [140 y_pos-dy 100 22];

            app.RadiocanalesEditFieldLabel = uilabel(app.UIFigure);
            app.RadiocanalesEditFieldLabel.HorizontalAlignment = 'right';
            app.RadiocanalesEditFieldLabel.Position = [30 y_pos-2*dy 100 22];
            app.RadiocanalesEditFieldLabel.Text = 'Radiocanales';
            app.RadiocanalesEditField = uieditfield(app.UIFigure, 'numeric');
            app.RadiocanalesEditField.Position = [140 y_pos-2*dy 100 22];

            app.CIRdBEditFieldLabel = uilabel(app.UIFigure);
            app.CIRdBEditFieldLabel.HorizontalAlignment = 'right';
            app.CIRdBEditFieldLabel.Position = [30 y_pos-3*dy 100 22];
            app.CIRdBEditFieldLabel.Text = 'CIR (dB)';
            app.CIRdBEditField = uieditfield(app.UIFigure, 'numeric');
            app.CIRdBEditField.Position = [140 y_pos-3*dy 100 22];

            app.PBDisenoEditFieldLabel = uilabel(app.UIFigure);
            app.PBDisenoEditFieldLabel.HorizontalAlignment = 'right';
            app.PBDisenoEditFieldLabel.Position = [30 y_pos-4*dy 100 22];
            app.PBDisenoEditFieldLabel.Text = 'PB (bloqueo)';
            app.PBDisenoEditField = uieditfield(app.UIFigure, 'numeric');
            app.PBDisenoEditField.Position = [140 y_pos-4*dy 100 22];

            app.PdropDisenoEditFieldLabel = uilabel(app.UIFigure);
            app.PdropDisenoEditFieldLabel.HorizontalAlignment = 'right';
            app.PdropDisenoEditFieldLabel.Position = [30 y_pos-5*dy 100 22];
            app.PdropDisenoEditFieldLabel.Text = 'Pdrop (caída)';
            app.PdropDisenoEditField = uieditfield(app.UIFigure, 'numeric');
            app.PdropDisenoEditField.Position = [140 y_pos-5*dy 100 22];

            app.DensidadEditFieldLabel = uilabel(app.UIFigure);
            app.DensidadEditFieldLabel.HorizontalAlignment = 'right';
            app.DensidadEditFieldLabel.Position = [30 y_pos-6*dy 100 22];
            app.DensidadEditFieldLabel.Text = 'Densidad (us/km²)';
            app.DensidadEditField = uieditfield(app.UIFigure, 'numeric');
            app.DensidadEditField.Position = [140 y_pos-6*dy 100 22];

            % ==========================================
            % COLUMNA 2: RESULTADOS Y CONFIGURACIÓN (Centro)
            % ==========================================
            app.TraficoTotalEditFieldLabel = uilabel(app.UIFigure);
            app.TraficoTotalEditFieldLabel.HorizontalAlignment = 'right';
            app.TraficoTotalEditFieldLabel.Position = [290 y_pos 120 22];
            app.TraficoTotalEditFieldLabel.Text = 'Tráfico Total (Erl)';
            app.TraficoTotalEditField = uieditfield(app.UIFigure, 'text');
            app.TraficoTotalEditField.Position = [420 y_pos 100 22];
            app.TraficoTotalEditField.Editable = 'off';

            app.PbEditFieldLabel = uilabel(app.UIFigure);
            app.PbEditFieldLabel.HorizontalAlignment = 'right';
            app.PbEditFieldLabel.Position = [290 y_pos-dy 120 22];
            app.PbEditFieldLabel.Text = 'Pb (bloqueo)';
            app.PbEditField = uieditfield(app.UIFigure, 'text');
            app.PbEditField.Position = [420 y_pos-dy 100 22];
            app.PbEditField.Editable = 'off';

            app.PhEditFieldLabel = uilabel(app.UIFigure);
            app.PhEditFieldLabel.HorizontalAlignment = 'right';
            app.PhEditFieldLabel.Position = [290 y_pos-2*dy 120 22];
            app.PhEditFieldLabel.Text = 'Ph (handover)';
            app.PhEditField = uieditfield(app.UIFigure, 'text');
            app.PhEditField.Position = [420 y_pos-2*dy 100 22];
            app.PhEditField.Editable = 'off';

            app.PdropEditFieldLabel = uilabel(app.UIFigure);
            app.PdropEditFieldLabel.HorizontalAlignment = 'right';
            app.PdropEditFieldLabel.Position = [290 y_pos-3*dy 120 22];
            app.PdropEditFieldLabel.Text = 'Pdrop (%)';
            app.PdropEditField = uieditfield(app.UIFigure, 'text');
            app.PdropEditField.Position = [420 y_pos-3*dy 100 22];
            app.PdropEditField.Editable = 'off';

            app.NumRecursosEditFieldLabel = uilabel(app.UIFigure);
            app.NumRecursosEditFieldLabel.HorizontalAlignment = 'right';
            app.NumRecursosEditFieldLabel.Position = [290 y_pos-4*dy 120 22];
            app.NumRecursosEditFieldLabel.Text = 'Recursos (TS)';
            app.NumRecursosEditField = uieditfield(app.UIFigure, 'text');
            app.NumRecursosEditField.Position = [420 y_pos-4*dy 100 22];
            app.NumRecursosEditField.Editable = 'off';

            app.RadioREditFieldLabel = uilabel(app.UIFigure);
            app.RadioREditFieldLabel.HorizontalAlignment = 'right';
            app.RadioREditFieldLabel.Position = [290 y_pos-5*dy 120 22];
            app.RadioREditFieldLabel.Text = 'Radio R (km)';
            app.RadioREditField = uieditfield(app.UIFigure, 'text');
            app.RadioREditField.Position = [420 y_pos-5*dy 100 22];
            app.RadioREditField.Editable = 'off';

            app.AreaCoberturaEditFieldLabel = uilabel(app.UIFigure);
            app.AreaCoberturaEditFieldLabel.HorizontalAlignment = 'right';
            app.AreaCoberturaEditFieldLabel.Position = [290 y_pos-6*dy 120 22];
            app.AreaCoberturaEditFieldLabel.Text = 'Área (km²)';
            app.AreaCoberturaEditField = uieditfield(app.UIFigure, 'text');
            app.AreaCoberturaEditField.Position = [420 y_pos-6*dy 100 22];
            app.AreaCoberturaEditField.Editable = 'off';

            app.AntenasDropDownLabel = uilabel(app.UIFigure);
            app.AntenasDropDownLabel.HorizontalAlignment = 'right';
            app.AntenasDropDownLabel.Position = [290 y_pos-7.5*dy 100 22];
            app.AntenasDropDownLabel.Text = 'Antenas';
            app.AntenasDropDown = uidropdown(app.UIFigure);
            app.AntenasDropDown.Position = [400 y_pos-7.5*dy 150 22];
            app.AntenasDropDown.Items = {'Omnidireccional', '120°', '60°'};
            app.AntenasDropDown.Value = 'Omnidireccional';

            % ==========================================
            % COLUMNA 3: ACCIONES (Derecha)
            % ==========================================
            btn_x = 600; btn_w = 150;
            
            app.CalcularButton = uibutton(app.UIFigure, 'push');
            app.CalcularButton.ButtonPushedFcn = createCallbackFcn(app, @CalcularButtonPushed, true);
            app.CalcularButton.Position = [btn_x y_pos btn_w 30];
            app.CalcularButton.Text = 'Calcular';

            app.CerrarButton = uibutton(app.UIFigure, 'push');
            app.CerrarButton.ButtonPushedFcn = createCallbackFcn(app, @CerrarButtonPushed, true);
            app.CerrarButton.Position = [btn_x y_pos-dy btn_w 30];
            app.CerrarButton.Text = 'Cerrar';

            % ==========================================
            % GRÁFICA (Abarca el tercio inferior completo)
            % ==========================================
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Probabilidad de bloqueo (Erlang-B)')
            xlabel(app.UIAxes, 'Número de canales (TS)')
            ylabel(app.UIAxes, 'Probabilidad de bloqueo')
            app.UIAxes.Position = [30 30 800 200]; 
            app.UIAxes.Toolbar.Visible = 'off'; 
            grid(app.UIAxes, 'on');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = Tema4
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

function Pb = erlang_b(A, N)
    if N == 0
        Pb = 1;
        return;
    end
    Pb = 1;
    for i = 1:N
        Pb = (A * Pb) / (i + A * Pb);
    end
end