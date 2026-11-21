classdef Portada < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure       matlab.ui.Figure
        CerrarButton   matlab.ui.control.Button
        Tema5Button    matlab.ui.control.Button
        Tema4Button    matlab.ui.control.Button
        Tema3Button    matlab.ui.control.Button
        Tema1y2Button  matlab.ui.control.Button
        Label          matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function: CerrarButton, UIFigure
        function btnCerrar(app, event)
            % Cierra la aplicación
            delete(app);
        end

        % Button pushed function: Tema1y2Button
        function btnTema12(app, event)
            % Abre la app de Temas 1 y 2
            Temas12();
        end

        % Button pushed function: Tema3Button
        function btnTema3(app, event)
            % Abre la app del Tema 3
            Tema3();
        end

        % Button pushed function: Tema4Button
        function btnTema4(app, event)
            % Abre la app del Tema 4
            Tema4();
        end

        % Button pushed function: Tema5Button
        function btnTema5(app, event)
            % Abre la app del Tema 5
            Tema5();
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Simulador de Comunicaciones Móviles';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @btnCerrar, true);

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.Position = [180 439 280 22];
            app.Label.Text = 'Simulador de Comunicaciones Móviles';
            app.Label.FontSize = 14;
            app.Label.FontWeight = 'bold';
            app.Label.HorizontalAlignment = 'center';

            % Create Tema1y2Button
            app.Tema1y2Button = uibutton(app.UIFigure, 'push');
            app.Tema1y2Button.ButtonPushedFcn = createCallbackFcn(app, @btnTema12, true);
            app.Tema1y2Button.Position = [270 380 120 30];
            app.Tema1y2Button.Text = 'Temas 1 y 2';

            % Create Tema3Button
            app.Tema3Button = uibutton(app.UIFigure, 'push');
            app.Tema3Button.ButtonPushedFcn = createCallbackFcn(app, @btnTema3, true);
            app.Tema3Button.Position = [270 330 120 30];
            app.Tema3Button.Text = 'Tema 3';

            % Create Tema4Button
            app.Tema4Button = uibutton(app.UIFigure, 'push');
            app.Tema4Button.ButtonPushedFcn = createCallbackFcn(app, @btnTema4, true);
            app.Tema4Button.Position = [270 280 120 30];
            app.Tema4Button.Text = 'Tema 4';

            % Create Tema5Button
            app.Tema5Button = uibutton(app.UIFigure, 'push');
            app.Tema5Button.ButtonPushedFcn = createCallbackFcn(app, @btnTema5, true);
            app.Tema5Button.Position = [270 230 120 30];
            app.Tema5Button.Text = 'Tema 5';

            % Create CerrarButton
            app.CerrarButton = uibutton(app.UIFigure, 'push');
            app.CerrarButton.ButtonPushedFcn = createCallbackFcn(app, @btnCerrar, true);
            app.CerrarButton.Position = [270 160 120 30];
            app.CerrarButton.Text = 'Cerrar';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Portada
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            delete(app.UIFigure)
        end
    end
end