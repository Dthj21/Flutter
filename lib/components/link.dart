import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String VOTE_MUTATION = '''
  mutation VoteMutation(\$linkId: Int!) {
    createVote(linkId: \$linkId) {
      link {
        id
        votes {
          id
        }
      }
    }
  }
''';

class LinkItem extends StatefulWidget {
  final int id;
  final String url;
  final String nombre;
  final String descripcion;
  final String precio;
  final String username;
  int votes;

  LinkItem({
    required this.id,
    required this.url,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.username,
    required this.votes,
  });

  @override
  _LinkItemState createState() => _LinkItemState();
}

class _LinkItemState extends State<LinkItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Imagen sin relación de aspecto
            Container(
              width: 100,
              child: Image.network(
                widget.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Nombre: ${widget.nombre}'),
                  Text('Descripcion: ${widget.descripcion}'),
                  Text('Precio: ${widget.precio}'),
                  Text('Url: ${widget.url}'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Posted by: ${widget.username}'),
                      Mutation(
                        options: MutationOptions(
                          document: gql(VOTE_MUTATION),
                          onCompleted: (dynamic resultData) {
                            setState(() {
                              widget.votes += 1;
                            });
                          },
                        ),
                        builder: (RunMutation runMutation, QueryResult? result) {
                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up, size: 16),
                                onPressed: () {
                                  runMutation({'linkId': widget.id});
                                },
                              ),
                              SizedBox(width: 5),
                              Text('${widget.votes}'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
