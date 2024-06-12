import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'link_list.dart';

const String CREATE_LINK_MUTATION = '''
  mutation PostMutation(
    \$nombre: String!
    \$descripcion: String!
    \$precio: String!
    \$url: String!
  ) {
    createLink(url: \$url, nombre: \$nombre, descripcion: \$descripcion, precio: \$precio) {
      id
      nombre
      descripcion
      precio
      url
    }
  }
''';

class CreateLinkScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final urlController = useTextEditingController();
    final nombreController = useTextEditingController();
    final descripcionController = useTextEditingController();
    final precioController = useTextEditingController();

    final createLinkMutation = useMutation(
      MutationOptions(
        document: gql(CREATE_LINK_MUTATION),
        onCompleted: (_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LinkListScreen()),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Link'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(labelText: 'The URL for the link'),
            ),
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: 'Descripcion'),
            ),
            TextField(
              controller: precioController,
              decoration: InputDecoration(labelText: 'Precio'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createLinkMutation.runMutation({
                  'url': urlController.text,
                  'nombre': nombreController.text,
                  'descripcion': descripcionController.text,
                  'precio': precioController.text,
                });
              },
              child: Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}