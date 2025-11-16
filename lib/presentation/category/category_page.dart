import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/presentation/category/category_view.dart';
import '../../core/di/service_locator.dart';
import 'category_bloc.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => CategoryBloc(
            getCategoriesAndTasks: sl(),
            createCategory: sl(),
            updateCategory: sl(),
            deleteCategory: sl(),
          )..add(LoadCategories()),
      child: const CategoryView(),
    );
  }
}
