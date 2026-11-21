classdef Tema5 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        ResultadoTextArea               matlab.ui.control.TextArea
        ResultadoTextAreaLabel          matlab.ui.control.Label
        CerrarButton                    matlab.ui.control.Button
        CalcularButton                  matlab.ui.control.Button
        FactorActividadEditField        matlab.ui.control.NumericEditField
        FactorActividadEditFieldLabel   matlab.ui.control.Label
        RbEditField                     matlab.ui.control.NumericEditField
        RbEditFieldLabel                matlab.ui.control.Label
        EbNoEditField                   matlab.ui.control.NumericEditField
        EbNoEditFieldLabel              matlab.ui.control.Label
        WEditField                      matlab.ui.control.NumericEditField
        WEditFieldLabel                 matlab.ui.control.Label
        DeltaNmaxEditField              matlab.ui.control.NumericEditField
        DeltaNmaxEditFieldLabel         matlab.ui.control.Label
        DeltaNEditField                 matlab.ui.control.NumericEditField
        DeltaNEditFieldLabel            matlab.ui.control.Label
        nEditField                      matlab.ui.control.NumericEditField
        nEditFieldLabel                 matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalcularButton
        function CalcularButtonPushed(app, event)
            % 1. Leer datos de entrada
            n = app.nEditField.Value;                % Factor de carga inicial
            DeltaN_actual = app.DeltaNEditField.Value; % Incremento de ruido actual (dB)
            DeltaN_max = app.DeltaNmaxEditField.Value; % Incremento máximo permitido (dB)
            W = app.WEditField.Value;                % Chip rate (Hz)
            EbNo_dB = app.EbNoEditField.Value;       % Eb/No objetivo (dB)
            Rb = app.RbEditField.Value;              % Velocidad de transmisión (bps)
            v = app.FactorActividadEditField.Value;  % Factor de actividad (0 a 1)
            
            % Validar datos
            if any([n, DeltaN_actual, DeltaN_max, W, EbNo_dB, Rb, v] <= 0)
                uialert(app.UIFigure, 'Todos los campos deben ser mayores que cero.', 'Error');
                return;
            end

            % 2. Convertir valores de dB a lineales
            EbNo_lin = 10^(EbNo_dB/10);
            DeltaN_actual_lin = 10^(DeltaN_actual/10);
            DeltaN_max_lin = 10^(DeltaN_max/10);

            % 3. Calcular el incremento de carga que aportaría el nuevo usuario
            % Fórmula 4.17: Delta_L = v / (1 + (W / (EbNo * Rb)))
            Delta_L = v / (1 + (W / (EbNo_lin * Rb)));

            % 4. Calcular el nuevo factor de carga total
            n_nuevo = n + Delta_L;

            % 5. Calcular el nuevo incremento de ruido
            % Fórmula: Delta_N = 1 / (1 - n)
            DeltaN_nuevo = 1 / (1 - n_nuevo);

            % 6. Verificar si el usuario es aceptado
            if DeltaN_nuevo <= DeltaN_max_lin
                mensaje = sprintf('USUARIO ACEPTADO\n\nFactor de carga nuevo: %.3f\nIncremento de ruido nuevo: %.2f dB\n(<= %.2f dB permitido)', ...
                    n_nuevo, 10*log10(DeltaN_nuevo), DeltaN_max);
                color_texto = [0 0.5 0]; % Verde
            else
                mensaje = sprintf('USUARIO RECHAZADO\n\nFactor de carga nuevo: %.3f\nIncremento de ruido nuevo: %.2f dB\n(> %.2f dB permitido)', ...
                    n_nuevo, 10*log10(DeltaN_nuevo), DeltaN_max);
                color_texto = [0.8 0 0]; % Rojo
            end

            % 7. Mostrar resultados en el área de texto
            app.ResultadoTextArea.Value = splitlines(mensaje);

            % 8. Graficar la relación entre factor de carga e incremento de ruido
            n_vec = linspace(0, 0.99, 100);
            DeltaN_vec = 10*log10(1 ./ (1 - n_vec));
            
            plot(app.UIAxes, n_vec, DeltaN_vec, 'b-', 'LineWidth', 2);
            hold(app.UIAxes, 'on');
            plot(app.UIAxes, n, DeltaN_actual, 'go', 'MarkerSize', 10, 'LineWidth', 2);
            plot(app.UIAxes, n_nuevo, 10*log10(DeltaN_nuevo), 'r*', 'MarkerSize', 12, 'LineWidth', 2);
            
            % Línea horizontal del máximo permitido
            yline(app.UIAxes, DeltaN_max, 'k--', 'Línea Máx', 'LineWidth', 1.5);
            
            hold(app.UIAxes, 'off');
            title(app.UIAxes, 'Incremento de Ruido vs Factor de Carga');
            xlabel(app.UIAxes, 'Factor de carga (n)');
            ylabel(app.UIAxes, 'Incremento de ruido (dB)');
            grid(app.UIAxes, 'on');
            legend(app.UIAxes, 'Curva teórica', 'Estado actual', 'Nuevo usuario', 'Máx permitido', 'Location', 'northwest');
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
            app.UIFigure.Name = 'Simulador - Tema 5 (CDMA)';

            % ==========================================
            % COLUMNA 1: ENTRADAS (Izquierda)
            % ==========================================
            y_pos = 590; dy = 38;

            app.nEditFieldLabel = uilabel(app.UIFigure);
            app.nEditFieldLabel.HorizontalAlignment = 'right';
            app.nEditFieldLabel.Position = [30 y_pos 100 22];
            app.nEditFieldLabel.Text = 'Factor de carga n';
            app.nEditField = uieditfield(app.UIFigure, 'numeric');
            app.nEditField.Position = [140 y_pos 100 22];

            app.DeltaNEditFieldLabel = uilabel(app.UIFigure);
            app.DeltaNEditFieldLabel.HorizontalAlignment = 'right';
            app.DeltaNEditFieldLabel.Position = [30 y_pos-dy 100 22];
            app.DeltaNEditFieldLabel.Text = 'Delta N actual (dB)';
            app.DeltaNEditField = uieditfield(app.UIFigure, 'numeric');
            app.DeltaNEditField.Position = [140 y_pos-dy 100 22];

            app.DeltaNmaxEditFieldLabel = uilabel(app.UIFigure);
            app.DeltaNmaxEditFieldLabel.HorizontalAlignment = 'right';
            app.DeltaNmaxEditFieldLabel.Position = [30 y_pos-2*dy 100 22];
            app.DeltaNmaxEditFieldLabel.Text = 'Delta N máx (dB)';
            app.DeltaNmaxEditField = uieditfield(app.UIFigure, 'numeric');
            app.DeltaNmaxEditField.Position = [140 y_pos-2*dy 100 22];

            app.WEditFieldLabel = uilabel(app.UIFigure);
            app.WEditFieldLabel.HorizontalAlignment = 'right';
            app.WEditFieldLabel.Position = [30 y_pos-3*dy 100 22];
            app.WEditFieldLabel.Text = 'W (chip rate)';
            app.WEditField = uieditfield(app.UIFigure, 'numeric');
            app.WEditField.Position = [140 y_pos-3*dy 100 22];

            app.EbNoEditFieldLabel = uilabel(app.UIFigure);
            app.EbNoEditFieldLabel.HorizontalAlignment = 'right';
            app.EbNoEditFieldLabel.Position = [30 y_pos-4*dy 100 22];
            app.EbNoEditFieldLabel.Text = 'Eb/No (dB)';
            app.EbNoEditField = uieditfield(app.UIFigure, 'numeric');
            app.EbNoEditField.Position = [140 y_pos-4*dy 100 22];

            app.RbEditFieldLabel = uilabel(app.UIFigure);
            app.RbEditFieldLabel.HorizontalAlignment = 'right';
            app.RbEditFieldLabel.Position = [30 y_pos-5*dy 100 22];
            app.RbEditFieldLabel.Text = 'Rb (bps)';
            app.RbEditField = uieditfield(app.UIFigure, 'numeric');
            app.RbEditField.Position = [140 y_pos-5*dy 100 22];

            app.FactorActividadEditFieldLabel = uilabel(app.UIFigure);
            app.FactorActividadEditFieldLabel.HorizontalAlignment = 'right';
            app.FactorActividadEditFieldLabel.Position = [30 y_pos-6*dy 100 22];
            app.FactorActividadEditFieldLabel.Text = 'Factor Actividad v';
            app.FactorActividadEditField = uieditfield(app.UIFigure, 'numeric');
            app.FactorActividadEditField.Position = [140 y_pos-6*dy 100 22];

            % ==========================================
            % COLUMNA 2: RESULTADOS (Centro)
            % ==========================================
            app.ResultadoTextAreaLabel = uilabel(app.UIFigure);
            app.ResultadoTextAreaLabel.HorizontalAlignment = 'right';
            app.ResultadoTextAreaLabel.Position = [290 y_pos 100 22];
            app.ResultadoTextAreaLabel.Text = 'Resultado:';
            
            app.ResultadoTextArea = uitextarea(app.UIFigure);
            app.ResultadoTextArea.Position = [400 y_pos-180 250 200];
            app.ResultadoTextArea.Editable = 'off';
            app.ResultadoTextArea.FontSize = 12;
            app.ResultadoTextArea.FontWeight = 'bold';

            % ==========================================
            % COLUMNA 3: ACCIONES (Derecha)
            % ==========================================
            btn_x = 680; btn_w = 120;
            
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
            title(app.UIAxes, 'Incremento de Ruido vs Factor de Carga')
            xlabel(app.UIAxes, 'Factor de carga (n)')
            ylabel(app.UIAxes, 'Incremento (dB)')
            app.UIAxes.Position = [30 30 800 220]; 
            app.UIAxes.Toolbar.Visible = 'off'; 
            grid(app.UIAxes, 'on');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = Tema5
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